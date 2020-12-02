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
    
    func update(_ calendar: EventKitCalendar) {
        self.dataStore.calendarIdentifers.set(isIncluded: calendar.isSubscribed,
                                                forKey: calendar.id)
    }

    func update(_ event: EventKitEvent) {

        self.dataStore.startedEventAlarms.set(isIncluded: event.didStartFiring,
                                                forKey: event.id)

        self.dataStore.firedEvents.set(isIncluded: event.hasFired,
                                         forKey: event.id)
    }
    
    func update(_ reminder: EventKitReminder) {
        
    }

    func isCalendarSubscribed(_ calendarID: String) -> Bool {
        return self.dataStore.calendarIdentifers.contains(calendarID)
    }
    
    func isEventSubscribed(_ eventID: String) -> Bool {
        return self.dataStore.unsubscribedEvents.contains(eventID) == false
    }
    
    func alarmHasStarted(eventID: String) -> Bool {
        return self.dataStore.startedEventAlarms.contains(eventID)
    }

    func alarmHasFired(eventID: String) -> Bool {
        return self.dataStore.firedEvents.contains(eventID)
    }

}
