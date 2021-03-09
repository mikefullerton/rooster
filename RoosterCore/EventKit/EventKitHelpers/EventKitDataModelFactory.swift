//
//  EKDataModelController+IntermediateModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/3/20.
//

import EventKit
import Foundation

/// This takes the two IntermediateDataModel structs and combines them into the Single and final EventKitDataModel
internal struct EventKitDataModelFactory {
    func createDataModel(withEKDataModel ekDataModel: EKDataModel) -> EventKitDataModel {
        let intermediateFactory = IntermediateFactory()

        let personalCalendarModel = intermediateFactory.createIntermediateDataModel(
            withEKEventStoreDataModel: ekDataModel.calendarStoreDataModel)

        let delegateCalendarModel = intermediateFactory.createIntermediateDataModel(
            withEKEventStoreDataModel: ekDataModel.delegateCalendarEventStoreDataModel)

        let personalCalendars = personalCalendarModel.calendars
        let delegateCalendars = delegateCalendarModel.calendars

        let events = personalCalendarModel.events + delegateCalendarModel.events

        let reminders = personalCalendarModel.reminders + delegateCalendarModel.reminders

        return EventKitDataModel(calendars: personalCalendars,
                                 delegateCalendars: delegateCalendars,
                                 events: events,
                                 reminders: reminders)
    }
}

extension EventKitDataModelFactory {
    struct IntermediateDataModel {
        let calendars: [EventKitCalendar]
        let events: [EventKitEvent]
        let reminders: [EventKitReminder]
    }

    struct IntermediateFactory: Loggable {
        private func calendar(forIdentifier identifier: String, inCalendars calendars: [EventKitCalendar]) -> EventKitCalendar? {
            calendars.first { $0.id == identifier }
        }

        private func createCalendars(ekDataModel: EKEventStoreDataModel) -> [EventKitCalendar] {
            var calendars: [EventKitCalendar] = []

            if let eventStore = ekDataModel.eventStore {
                for ekCalendar in ekDataModel.calendars {
                    let calendar = EventKitCalendar(withIdentifier: ekCalendar.uniqueID,
                                                    ekCalendar: ekCalendar,
                                                    ekEventStore: eventStore)

                    calendars.append(calendar)
                }
            }

            return calendars
        }

        private func createEvents(ekDataModel: EKEventStoreDataModel, withCalendars calendars: [EventKitCalendar]) -> [EventKitEvent] {
            var events: [EventKitEvent] = []

            for ekEvent in ekDataModel.events {
                guard let calendar = self.calendar(forIdentifier: ekEvent.calendar.uniqueID, inCalendars: calendars) else {
                    self.logger.error("Error couldn't find calendar for id: \(ekEvent.calendar.uniqueID)")
                    continue
                }

                events.append(EventKitEvent(ekEvent: ekEvent, calendar: calendar))
            }

            return events
        }

        private func createReminders(ekDataModel: EKEventStoreDataModel,
                                     withCalendars calendars: [EventKitCalendar]) -> [EventKitReminder] {
            var reminders: [EventKitReminder] = []

            for ekReminder in ekDataModel.reminders {
                guard let calendar = self.calendar(forIdentifier: ekReminder.calendar.uniqueID, inCalendars: calendars) else {
                    self.logger.error("Error couldn't find calendar for id: \(ekReminder.calendar.uniqueID)")
                    continue
                }
                // swiftlint:disable todo
                // TODO: check alarms?
                // swiftlint:enable todo

                if ekReminder.isCompleted {
                    continue
                }

                reminders.append(EventKitReminder(ekReminder: ekReminder,
                                                  calendar: calendar))
            }

            return reminders
        }

        public func createIntermediateDataModel(withEKEventStoreDataModel dataModel: EKEventStoreDataModel) -> IntermediateDataModel {
            let calendars = self.createCalendars(ekDataModel: dataModel)
            let events = self.createEvents(ekDataModel: dataModel, withCalendars: calendars)
            let reminders = self.createReminders(ekDataModel: dataModel, withCalendars: calendars)

            return IntermediateDataModel(calendars: calendars, events: events, reminders: reminders)
        }
    }
}

extension EKEvent {
    public var isMultiDay: Bool {
        if let days = Date.daysBetween(lhs: self.startDate, rhs: self.endDate) {
            return days > 1
        }

        return false
    }

    public func occursWithinRange(start: Date, end: Date) -> Bool {
        Date.range(self.startDate...self.endDate, intersectsRange: start...end)
    }
}
