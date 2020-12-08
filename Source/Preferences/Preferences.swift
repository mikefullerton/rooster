//
//  PreferencesDataModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation

class Preferences {
    static let DidChangeEvent = Notification.Name(rawValue: "PreferencesDidChangeEvent")
    
    private let dataStore: PreferencesDataStore
    
    public static let instance = Preferences()
 
    private init() {
        self.dataStore = PreferencesDataStore()
    }
    
    func notify() {
        NotificationCenter.default.post(name: Preferences.DidChangeEvent,
                                        object: self,
                                        userInfo: nil)
    }
    
    // MARK: calendars
    
    func update(calendar: EventKitCalendar) {
        self.dataStore.subscribedCalendars.set(isIncluded: calendar.isSubscribed,
                                                forKey: calendar.id)
    }
    
    func isCalendarSubscribed(_ calendarID: String) -> Bool {
        return self.dataStore.subscribedCalendars.contains(calendarID)
    }
    
    // MARK: events

    func update(event: EventKitEvent) {
        let savedState = EventKitEvent.SavedState(withEvent: event)
        self.dataStore.events.set(value:savedState.asDictionary, forKey: event.id)
        
        self.update(alarm: event.alarm, forIdentifier: event.id)
    }
    
    func eventState(forKey key: String) -> EventKitEvent.SavedState? {
        if let dictionary = self.dataStore.events.value(forKey: key) as? [AnyHashable: Any] {
            return EventKitEvent.SavedState(withDictionary: dictionary)
        }

        return nil
    }

    // MARK: reminders

    func update(reminder: EventKitReminder) {
        let savedState = EventKitReminder.SavedState(withReminder: reminder)
        self.dataStore.reminders.set(value:savedState.asDictionary, forKey: reminder.id)

        self.update(alarm: reminder.alarm, forIdentifier: reminder.id)
    }

    func reminderState(forKey key: String) -> EventKitReminder.SavedState? {
        if let dictionary = self.dataStore.events.value(forKey: key) as? [AnyHashable: Any] {
            return EventKitReminder.SavedState(withDictionary: dictionary)
        }
        
        return nil
    }


    // MARK: alarms
    
    private func update(alarm: EventKitAlarm, forIdentifier identifier: String) {
        let savedState = EventKitAlarm.SavedState(withAlarm: alarm)
        self.dataStore.alarms.set(value: savedState.asDictionary, forKey: identifier)
    }

    private func alarmState(forKey key: String) -> EventKitAlarm.SavedState? {
        if let dictionary = self.dataStore.events.value(forKey: key) as? [AnyHashable: Any] {
            return EventKitAlarm.SavedState(withDictionary: dictionary)
        }
        return nil
    }

    


    // MARK: sounds

    var sounds: Sounds {
        get {
            return Sounds(withDictionary: self.dataStore.sounds.dictionary)
        }
        set(sounds) {
            self.dataStore.sounds.replaceAll(sounds.asDictionary)
        }
    }

}
