//
//  Preferences.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation

class PreferencesDataStore {
 
    class IdentifierList {
        private let preferencesKey: String
        private var identifiers: [String]

        init(withPreferencesKey key: String) {
            self.preferencesKey = key
            self.identifiers = UserDefaults.standard.stringArray(forKey: preferencesKey) ?? []
        }

        private func save() {
            if let oldIdentifiers = UserDefaults.standard.stringArray(forKey: preferencesKey) {
               if self.identifiers == oldIdentifiers {
                    return
               }
            }

            UserDefaults.standard.set(self.identifiers, forKey: self.preferencesKey)
            UserDefaults.standard.synchronize()
        }
        
        func add(identifier: String) {
            if !self.identifiers.contains(identifier) {
                self.identifiers.append(identifier)
                self.save()
            }
        }

        func remove(identifier: String) {
            if let index = self.identifiers.firstIndex(of: identifier) {
                self.identifiers.remove(at: index)
                self.save()
            }
        }

        func set(isIncluded included: Bool, forKey key: String) {
            if included {
                self.add(identifier: key)
            } else {
                self.remove(identifier: key)
            }
        }
        
        func removeAll(notifyListeners notify: Bool = true) {
            self.identifiers.removeAll()
            self.save()
        }
        
        func replaceAll(withIdentifiers newIdentifiers: [String]) {
            self.identifiers = newIdentifiers
            self.save()
        }
        
        func contains(_ id: String) -> Bool {
            return self.identifiers.contains(id)
        }
    }
    
    let calendarIdentifers: IdentifierList
    let unsubscribedEvents: IdentifierList
    let startedEventAlarms: IdentifierList
    let unsubscribedReminders: IdentifierList
    let firedEvents: IdentifierList
    
    init() {
        self.calendarIdentifers = IdentifierList(withPreferencesKey: "calendars")
        self.unsubscribedEvents = IdentifierList(withPreferencesKey: "events")
        self.unsubscribedReminders = IdentifierList(withPreferencesKey: "reminders")
        self.firedEvents = IdentifierList(withPreferencesKey: "fired-events")
        self.startedEventAlarms = IdentifierList(withPreferencesKey: "started-alarms")
    }
}

