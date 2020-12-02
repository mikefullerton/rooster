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
        self.dataStore.subscribedCalendars.set(isIncluded: calendar.isSubscribed,
                                                forKey: calendar.id)
    }

    func update(_ event: EventKitEvent) {
        self.dataStore.alarmStates.set(value: event.alarmState.rawValue, forKey: event.id)
    }

    func alarmState(forEventID eventID: String) -> EventKitEvent.AlarmState? {
        if let state = self.dataStore.alarmStates.value(forKey: eventID) as? String {
            return EventKitEvent.AlarmState(rawValue: state)
        }
        
        return nil
    }
    
    func update(_ reminder: EventKitReminder) {
        
    }

    func isCalendarSubscribed(_ calendarID: String) -> Bool {
        return self.dataStore.subscribedCalendars.contains(calendarID)
    }
    
    func isEventSubscribed(_ eventID: String) -> Bool {
        return self.dataStore.unsubscribedEvents.contains(eventID) == false
    }
    

}
