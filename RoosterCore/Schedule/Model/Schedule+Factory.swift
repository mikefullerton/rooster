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
                                      calendar: ScheduleCalendar,
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

                if !dayRange.isAllDay || scheduleBehavior.eventScheduleBehavior.showAllDayEvents {
                    let scheduleItem = EventScheduleItem(withEvent: eventKitEvent,
                                                         calendar: calendar,
                                                         dateRange: dayRange,
                                                         storageRecord: storageRecord,
                                                         scheduleBehavior: scheduleBehavior)

                    events.append(scheduleItem)
                }
            }

            return events
        }

        private func createReminderItems(eventKitReminder: EventKitReminder,
                                         calendar: ScheduleCalendar,
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

            for calendarItem in calendarItems {
                if let calendar = calendars.calendar(forID: calendarItem.calendar.id) {
                    if let event = calendarItem as? EventKitEvent {
                        if let scheduleItems = self.createEventItems(eventKitEvent: event,
                                                                     calendar: calendar,
                                                                     storageRecord: storedEvents[calendarItem.id],
                                                                     scheduleBehavior: scheduleBehavior,
                                                                     visibleRange: visibleRange) {
                            items.append(contentsOf: scheduleItems)
                        }
                    } else if let reminder = calendarItem as? EventKitReminder {
                        if let reminders = self.createReminderItems(eventKitReminder: reminder,
                                                                    calendar: calendar,
                                                                    storageRecord: storedReminders[calendarItem.id],
                                                                    scheduleBehavior: scheduleBehavior,
                                                                    visibleRange: visibleRange) {
                            items.append(contentsOf: reminders)
                        }
                    }
                } else {
                    assertionFailure("failed to load schedule calendar")
                }
            }

            return items
        }

        private func createCalendarGroups(from eventKitCalendars: [EventKitCalendar],
                                          storedCalendars: [String: ScheduleCalendarStorageRecord],
                                          scheduleBehavior: ScheduleBehavior) -> [CalendarGroup] {
            var intermediateCalendars: [String: [EventKitCalendar]] = [:]

            for calendar in eventKitCalendars {
                if var list = intermediateCalendars[calendar.source.title] {
                    list.append(calendar)
                    intermediateCalendars[calendar.source.title] = list
                } else {
                    intermediateCalendars[calendar.source.title] = [calendar]
                }
            }

            var outCalendars: [CalendarGroup] = []

            for (source, calendars) in intermediateCalendars {
                var calendarScheduleItems: [ScheduleCalendar] = []

                calendars.forEach { calendar in
                    let storedData = storedCalendars[calendar.id] ??
                    ScheduleCalendarStorageRecord.default

                    calendarScheduleItems.append(ScheduleCalendar(calendar: calendar, storageRecord: storedData))
                }

                outCalendars.append(CalendarGroup(withCalendarSource: source, calendars: calendarScheduleItems))
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
