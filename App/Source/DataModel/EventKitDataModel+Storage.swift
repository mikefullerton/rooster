//
//  DataModelStorage.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation

extension EventKitDataModel {

    /// Where we store the data we're interested in for our EventKitDataModel
    class Storage {
        
        public static var instance = Storage()
        
        private let subscribedCalendars: UserDefaults.IdentifierList
        private let events: UserDefaults.IdentifierDictionary
        private let reminders: UserDefaults.IdentifierDictionary
        private let alarms: UserDefaults.IdentifierDictionary

        private init() {
            self.subscribedCalendars = UserDefaults.IdentifierList(withPreferencesKey: "calendars")
            self.events = UserDefaults.IdentifierDictionary(withPreferencesKey: "events")
            self.reminders = UserDefaults.IdentifierDictionary(withPreferencesKey: "reminders")
            self.alarms = UserDefaults.IdentifierDictionary(withPreferencesKey: "alarms")
        }
        
        // MARK: calendars
        
        func update(calendar: EventKitCalendar) {
            self.subscribedCalendars.set(isIncluded: calendar.isSubscribed,
                                         forKey: calendar.id)
        }
        
        func isCalendarSubscribed(_ calendarID: String) -> Bool {
            return self.subscribedCalendars.contains(calendarID)
        }
        
        // MARK: events

        func update(event: EventKitEvent) {
            let savedState = EventKitEvent.SavedState(withEvent: event)
            self.events.set(value:savedState.dictionaryRepresentation, forKey: event.id)
            
            self.update(alarm: event.alarm, forIdentifier: event.id)
        }
        
        func eventState(forKey key: String) -> EventKitEvent.SavedState? {
            if let dictionary = self.events.value(forKey: key) as? [AnyHashable: Any] {
                return EventKitEvent.SavedState(withDictionary: dictionary)
            }

            return nil
        }

        // MARK: reminders

        func update(reminder: EventKitReminder) {
            let savedState = EventKitReminder.SavedState(withReminder: reminder)
            self.reminders.set(value:savedState.dictionaryRepresentation, forKey: reminder.id)

            self.update(alarm: reminder.alarm, forIdentifier: reminder.id)
        }

        func reminderState(forKey key: String) -> EventKitReminder.SavedState? {
            if let dictionary = self.events.value(forKey: key) as? [AnyHashable: Any] {
                return EventKitReminder.SavedState(withDictionary: dictionary)
            }
            
            return nil
        }


        // MARK: alarms
        
        private func update(alarm: EventKitAlarm,
                            forIdentifier identifier: String) {
            let savedState = EventKitAlarm.SavedState(withAlarm: alarm)
            self.alarms.set(value: savedState.dictionaryRepresentation, forKey: identifier)
        }

        private func alarmState(forKey key: String) -> EventKitAlarm.SavedState? {
            if let dictionary = self.events.value(forKey: key) as? [AnyHashable: Any] {
                return EventKitAlarm.SavedState(withDictionary: dictionary)
            }
            return nil
        }

        
    }
}
