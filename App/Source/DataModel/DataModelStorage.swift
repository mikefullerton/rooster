//
//  DataModelStorage.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation


/// Where we store the data we're interested in for our DataModel
class DataModelStorage {
    
    private let subscribedCalendars: UserDefaults.IdentifierList
    private let events: UserDefaults.IdentifierDictionary
    private let reminders: UserDefaults.IdentifierDictionary
    private let alarms: UserDefaults.IdentifierDictionary

    init() {
        self.subscribedCalendars = UserDefaults.IdentifierList(withPreferencesKey: "calendars")
        self.events = UserDefaults.IdentifierDictionary(withPreferencesKey: "events")
        self.reminders = UserDefaults.IdentifierDictionary(withPreferencesKey: "reminders")
        self.alarms = UserDefaults.IdentifierDictionary(withPreferencesKey: "alarms")
    }
    
    // MARK: calendars
    
    func update(calendar: Calendar) {
        self.subscribedCalendars.set(isIncluded: calendar.isSubscribed,
                                     forKey: calendar.id)
    }
    
    func isCalendarSubscribed(_ calendarID: String) -> Bool {
        return self.subscribedCalendars.contains(calendarID)
    }
    
    // MARK: events

    func update(event: Event) {
        let savedState = Event.SavedState(withEvent: event)
        self.events.set(value:savedState.dictionaryRepresentation, forKey: event.id)
        
        self.update(alarm: event.alarm, forIdentifier: event.id)
    }
    
    func eventState(forKey key: String) -> Event.SavedState? {
        if let dictionary = self.events.value(forKey: key) as? [AnyHashable: Any] {
            return Event.SavedState(withDictionary: dictionary)
        }

        return nil
    }

    // MARK: reminders

    func update(reminder: Reminder) {
        let savedState = Reminder.SavedState(withReminder: reminder)
        self.reminders.set(value:savedState.dictionaryRepresentation, forKey: reminder.id)

        self.update(alarm: reminder.alarm, forIdentifier: reminder.id)
    }

    func reminderState(forKey key: String) -> Reminder.SavedState? {
        if let dictionary = self.events.value(forKey: key) as? [AnyHashable: Any] {
            return Reminder.SavedState(withDictionary: dictionary)
        }
        
        return nil
    }


    // MARK: alarms
    
    private func update(alarm: Alarm,
                        forIdentifier identifier: String) {
        let savedState = Alarm.SavedState(withAlarm: alarm)
        self.alarms.set(value: savedState.dictionaryRepresentation, forKey: identifier)
    }

    private func alarmState(forKey key: String) -> Alarm.SavedState? {
        if let dictionary = self.events.value(forKey: key) as? [AnyHashable: Any] {
            return Alarm.SavedState(withDictionary: dictionary)
        }
        return nil
    }
}
