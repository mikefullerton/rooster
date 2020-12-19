//
//  Preferences.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation

struct PreferencesDataStore {
 
    let subscribedCalendars: IdentifierList
    
    let sounds: IdentifierDictionary
    
    let events: IdentifierDictionary
    
    let reminders: IdentifierDictionary
    
    let alarms: IdentifierDictionary

    init() {
        self.subscribedCalendars = IdentifierList(withPreferencesKey: "calendars")
        self.events = IdentifierDictionary(withPreferencesKey: "events")
        self.reminders = IdentifierDictionary(withPreferencesKey: "reminders")
        self.sounds = IdentifierDictionary(withPreferencesKey: "sounds")
        self.alarms = IdentifierDictionary(withPreferencesKey: "alarms")
    }
    
    func setBool(_ value: Bool, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func bool(forKey key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
}

