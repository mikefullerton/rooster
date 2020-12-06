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
    
    // MARK: model objects
    
    func update(calendar: EventKitCalendar) {
        self.dataStore.subscribedCalendars.set(isIncluded: calendar.isSubscribed,
                                                forKey: calendar.id)
    }

    func update(event: EventKitEvent) {
        let serializer = SerializedEventKitItem(withEventKitItem:event)
        self.dataStore.events.set(value:serializer.asDictionary, forKey: event.id)
    }

    func event(forKey key: String) -> SerializedEventKitItem<EventKitEvent>? {
        if let dictionary = self.dataStore.events.value(forKey: key) as? [AnyHashable: Any] {
            return SerializedEventKitItem(withDictionary: dictionary)
        }
        
        return nil
    }

    func update(reminder: EventKitReminder) {
        let serializer = SerializedEventKitItem(withEventKitItem:reminder)
        self.dataStore.reminders.set(value:serializer.asDictionary, forKey: reminder.id)
    }

    func reminder(forKey key: String) -> SerializedEventKitItem<EventKitReminder>? {
        if let dictionary = self.dataStore.events.value(forKey: key) as? [AnyHashable: Any] {
            return SerializedEventKitItem(withDictionary: dictionary)
        }
        
        return nil
    }

    func isCalendarSubscribed(_ calendarID: String) -> Bool {
        return self.dataStore.subscribedCalendars.contains(calendarID)
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
