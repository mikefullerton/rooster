//
//  EKDataModelController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/3/20.
//

import EventKit
import Foundation

/// this asychronously fetches all the EKCalendars, EKEvents, and EKReminders we're interested in.
/// All the fetched data is later used to Create our EventKitCalendars, EventKitEvents, and EventKitReminders.
internal struct EKDataModelFactory: Loggable {
    private let store: EKEventStore

    let rules: EKDataModelControllerRules

    init(store: EKEventStore,
         rules: EKDataModelControllerRules) {
        self.store = store
        self.rules = rules
    }

    func fetchCalendars() -> [EKCalendar] {
        var calendars: [EKCalendar] = []

        let eventCalendars = self.store.calendars(for: .event)
        calendars += eventCalendars

        #if REMINDERS
        let remindersCalendars = self.store.calendars(for: .reminder)
        calendars += remindersCalendars
        #endif

        return calendars
    }

    func fetchDataModel(withCalendars calendars: [EKCalendar],
                        completion: @escaping (_ dataModel: EKEventStoreDataModel) -> Void) {
        let events = self.fetchEvents(withCalendars: calendars)

        #if REMINDERS
        self.fetchReminders(withCalendars: calendars) { reminders in
            completion(EKEventStoreDataModel(eventStore: self.store,
                                             calendars: calendars,
                                             events: events,
                                             reminders: reminders))
        }
        #else
        completion(EKEventStoreDataModel(eventStore: self.store,
                                         calendars: calendars,
                                         events: events,
                                         reminders: []))
        #endif
    }

    // MARK: private

    private func subscribedCalendars(_ calendars: [EKCalendar]) -> [EKCalendar] {
        var subscribedCalendars: [EKCalendar] = []
        for calendar in calendars {
            let subscribed = self.rules.isCalendarEnabled(calendarID: calendar.uniqueID) ||
                                self.rules.isDelegateCalendarEnabled(calendarID: calendar.uniqueID)

            if subscribed {
                subscribedCalendars.append(calendar)
            }
        }

        return subscribedCalendars
    }

    private func calendarNames(forCalendars calendars: [EKCalendar]) -> [String] {
        var list: [String] = []
        calendars.forEach {
            list.append("\($0.source.title): \($0.title)")
        }
        return list
    }

    private func fetchEvents(withCalendars calendars: [EKCalendar]) -> [EKEvent] {
        let subscribedCalendars = self.subscribedCalendars(calendars)

        if subscribedCalendars.isEmpty {
            return []
        }
        let dateRange = self.rules.dateRange
        let predicate = store.predicateForEvents(withStart: dateRange.startDate,
                                                 end: dateRange.endDate,
                                                 calendars: subscribedCalendars)

        let events = store.events(matching: predicate)
        self.logger.log("""
            Loaded \(events.count) events for calendars: \
            \(self.calendarNames(forCalendars: calendars).joined(separator: ", ")), in range: \(dateRange.description)
            """)
        return events
    }

    private func fetchReminders(withCalendars calendars: [EKCalendar],
                                completion: @escaping ([EKReminder]) -> Void) {
        let subscribedCalendars = self.subscribedCalendars(calendars)

        if subscribedCalendars.isEmpty {
            completion([])
            return
        }

        let predicate = store.predicateForIncompleteReminders(withDueDateStarting: nil,
                                                              ending: nil,
                                                              calendars: subscribedCalendars)

        store.fetchReminders(matching: predicate) { fetchedReminders in
            self.logger.log("""
                Loaded \(fetchedReminders?.count ?? 0) reminders for \
                calendars: \(self.calendarNames(forCalendars: calendars).joined(separator: ", "))
                """)

            if let reminders = fetchedReminders {
                completion(reminders)
            } else {
                completion([])
            }
        }
    }
}
