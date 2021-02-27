//
//  DataModelStorage.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation


/// Where we store the data we're interested in for our RCCalendarDataModel
public class DataModelStorage {
    
    private let subscribedCalendars: UserDefaults.IdentifierList
    private let events: UserDefaults.IdentifierDictionary
    private let reminders: UserDefaults.IdentifierDictionary
    private let alarms: UserDefaults.IdentifierDictionary

    public init() {
        self.subscribedCalendars = UserDefaults.IdentifierList(withPreferencesKey: "calendars")
        self.events = UserDefaults.IdentifierDictionary(withPreferencesKey: "events")
        self.reminders = UserDefaults.IdentifierDictionary(withPreferencesKey: "reminders")
        self.alarms = UserDefaults.IdentifierDictionary(withPreferencesKey: "alarms")
    }
    
    // MARK: calendars
    
    public func update(calendar: RCCalendar) {
        self.subscribedCalendars.set(isIncluded: calendar.isSubscribed,
                                     forKey: calendar.id)
    }
    
    public func isCalendarSubscribed(_ calendarID: String) -> Bool {
        return self.subscribedCalendars.contains(calendarID)
    }
    
    // MARK: events

    public func update(event: RCEvent) {
        let savedState = RCEvent.SavedState(withEvent: event)
        self.events.set(value:savedState.dictionaryRepresentation, forKey: event.id)
        
        self.update(alarm: event.alarm, forIdentifier: event.id)
    }
    
    public func eventState(forKey key: String) -> RCEvent.SavedState? {
        if let dictionary = self.events.value(forKey: key) as? [AnyHashable: Any] {
            return RCEvent.SavedState(withDictionary: dictionary)
        }

        return nil
    }

    // MARK: reminders

    public func update(reminder: RCReminder) {
        let savedState = RCReminder.SavedState(withReminder: reminder)
        self.reminders.set(value:savedState.dictionaryRepresentation, forKey: reminder.id)

        self.update(alarm: reminder.alarm, forIdentifier: reminder.id)
    }

    public func reminderState(forKey key: String) -> RCReminder.SavedState? {
        if let dictionary = self.events.value(forKey: key) as? [AnyHashable: Any] {
            return RCReminder.SavedState(withDictionary: dictionary)
        }
        
        return nil
    }


    // MARK: alarms
    
    private func update(alarm: RCAlarm,
                        forIdentifier identifier: String) {
        let savedState = RCAlarm.SavedState(withAlarm: alarm)
        self.alarms.set(value: savedState.dictionaryRepresentation, forKey: identifier)
    }

    private func alarmState(forKey key: String) -> RCAlarm.SavedState? {
        if let dictionary = self.events.value(forKey: key) as? [AnyHashable: Any] {
            return RCAlarm.SavedState(withDictionary: dictionary)
        }
        return nil
    }
}
