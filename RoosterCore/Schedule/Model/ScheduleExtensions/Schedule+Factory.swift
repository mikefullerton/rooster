//
//  ScheduleItemFactory.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/3/21.
//

import Foundation

extension Schedule {
    public struct Factory: Loggable {
        public init() {
        }

        private func createEventItems(eventKitEvent: EventKitEvent,
                                      calendar: CalendarScheduleItem,
                                      storageRecord: EventScheduleItemStorageRecord?,
                                      scheduleBehavior: ScheduleBehavior,
                                      visibleRange: DateRange) -> [EventScheduleItem]? {
            guard scheduleBehavior.eventScheduleBehavior.showDeclinedEvents || eventKitEvent.participationStatus != .declined else {
                return nil
            }

            guard scheduleBehavior.eventScheduleBehavior.showAllDayEvents || !eventKitEvent.isAllDay else {
                return nil
            }

            let storageRecord = storageRecord == nil ? EventScheduleItem.createStorageRecord(withEventKitEvent: eventKitEvent,
                                                                                             scheduleBehavior: scheduleBehavior) : storageRecord!

            let dateRange = DateRange(startDate: eventKitEvent.startDate,
                                      endDate: eventKitEvent.endDate)

            var events: [EventScheduleItem] = []

            let dayRanges = dateRange.dayRanges
            for dayRange in dayRanges {
                guard visibleRange.contains(dayRange.startDate) || visibleRange.contains(dayRange.endDate) else {
                    // not in range of dates
                    continue
                }

                let scheduleItem = EventScheduleItem(withEvent: eventKitEvent,
                                                     calendar: calendar,
                                                     dateRange: dayRange,
                                                     storageRecord: storageRecord,
                                                     scheduleBehavior: scheduleBehavior)

                events.append(scheduleItem)
            }

            return events
        }

        private func createReminderItems(eventKitReminder: EventKitReminder,
                                         calendar: CalendarScheduleItem,
                                         storageRecord: ReminderScheduleItemStorageRecord?,
                                         scheduleBehavior: ScheduleBehavior,
                                         visibleRange: DateRange) -> [ReminderScheduleItem]? {
            // FUTURE: multiday reminders??

            let storageRecord = storageRecord == nil ? ReminderScheduleItem.createStorageRecord(withEventKitReminder: eventKitReminder,
                                                                                                scheduleBehavior: scheduleBehavior) : storageRecord!

            if let startDate = eventKitReminder.scheduleStartDate {
                guard startDate.isBeforeDate(visibleRange.endDate) else {
                    return nil
                }

                return [
                    ReminderScheduleItem(withReminder: eventKitReminder,
                                         calendar: calendar,
                                         storageRecord: storageRecord,
                                         scheduleBehavior: scheduleBehavior)
                ]
            }

            guard scheduleBehavior.reminderScheduleBehavior.showAllReminders else {
                // we don't have a date, and pref is off, so don't show this reminder
                return nil
            }

            guard scheduleBehavior.reminderScheduleBehavior.priorityFilter <= eventKitReminder.priority else {
                return nil
            }

            // show reminder with no date
            let reminder = ReminderScheduleItem(withReminder: eventKitReminder,
                                                calendar: calendar,
                                                storageRecord: storageRecord,
                                                scheduleBehavior: scheduleBehavior)

            return [reminder]
        }

        private func createScheduleItems(from calendarItems: [EventKitCalendarItem],
                                         storedEvents: [String: EventScheduleItemStorageRecord],
                                         storedReminders: [String: ReminderScheduleItemStorageRecord],
                                         calendars: Calendars,
                                         scheduleBehavior: ScheduleBehavior) -> [ScheduleItem] {
            let visibleRange = scheduleBehavior.calendarScheduleBehavior.visibleDateRange

            var items: [ScheduleItem] = []

            for item in calendarItems {
                if let calendar = calendars.calendar(forID: item.calendar.id) {
                    if let event = item as? EventKitEvent {
                        if let scheduleItems = self.createEventItems(eventKitEvent: event,
                                                                     calendar: calendar,
                                                                     storageRecord: storedEvents[item.id],
                                                                     scheduleBehavior: scheduleBehavior,
                                                                     visibleRange: visibleRange) {
                            items.append(contentsOf: scheduleItems)
                        }
                    } else if let reminder = item as? EventKitReminder {
                        if let reminders = self.createReminderItems(eventKitReminder: reminder,
                                                                    calendar: calendar,
                                                                    storageRecord: storedReminders[item.id],
                                                                    scheduleBehavior: scheduleBehavior,
                                                                    visibleRange: visibleRange) {
                            items.append(contentsOf: reminders)
                        }
                    }
                }
            }

            return items
        }

        private func createCalendarGroups(from eventKitCalendars: [EventKitCalendar],
                                          storedCalendars: [String: CalendarScheduleItemStorageRecord],
                                          scheduleBehavior: ScheduleBehavior) -> [CalendarGroup] {
            var intermediateCalendars: [CalendarSource: [EventKitCalendar]] = [:]

            for calendar in eventKitCalendars {
                if var list = intermediateCalendars[calendar.sourceTitle] {
                    list.append(calendar)
                    intermediateCalendars[calendar.sourceTitle] = list
                } else {
                    intermediateCalendars[calendar.sourceTitle] = [calendar]
                }
            }

            var outCalendars: [CalendarGroup] = []

            for (source, calendars) in intermediateCalendars {
                var calendarItems: [CalendarScheduleItem] = []

                calendars.forEach { calendar in
                    let storedData = storedCalendars[calendar.id] ??
                    CalendarScheduleItemStorageRecord.default

                    calendarItems.append(CalendarScheduleItem(calendar: calendar, storageRecord: storedData))
                }

                outCalendars.append(CalendarGroup(withCalendarSource: source, calendars: calendarItems))
            }

            return outCalendars
        }

        public func createSchedule(withStoredScheduleData storedScheduleData: ScheduleStorageRecord,
                                   eventKitDataModel: EventKitDataModel,
                                   scheduleBehavior: ScheduleBehavior) -> Schedule {
            let calendarGroups = self.createCalendarGroups(from: eventKitDataModel.calendars,
                                                           storedCalendars: storedScheduleData.calendars,
                                                           scheduleBehavior: scheduleBehavior)

            let delegateCalendarGroups = self.createCalendarGroups(from: eventKitDataModel.delegateCalendars,
                                                                   storedCalendars: storedScheduleData.delegateCalendars,
                                                                   scheduleBehavior: scheduleBehavior)

            let calendars = Calendars(calendarGroups: calendarGroups,
                                      delegateCalendarGroups: delegateCalendarGroups)

            let allItems: [EventKitCalendarItem] = eventKitDataModel.events + eventKitDataModel.reminders

            let items = self.createScheduleItems(from: allItems,
                                                 storedEvents: storedScheduleData.events,
                                                 storedReminders: storedScheduleData.reminders,
                                                 calendars: calendars,
                                                 scheduleBehavior: scheduleBehavior)

            let sortedItems = items.sorted(by: Schedule.itemSorter)

            return Schedule(calendars: calendars, items: sortedItems)
        }
    }
}
