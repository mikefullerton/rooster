//
//  Preferences.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation

class Preferences {
    
    static let DidChangeEvent = Notification.Name(rawValue: "PreferencesDidChangeEvent")

    class IdentifierList {
        private let preferencesKey: String
        
        private var identifiers: [String]

        init(withPreferencesKey key: String) {
            self.preferencesKey = key
            self.identifiers = UserDefaults.standard.stringArray(forKey: preferencesKey) ?? []
        }

        private func save(notifyListeners notify: Bool) {
            if let oldIdentifiers = UserDefaults.standard.stringArray(forKey: preferencesKey) {
               if self.identifiers == oldIdentifiers {
                    return
               }
            }

            UserDefaults.standard.set(self.identifiers, forKey: self.preferencesKey)
            UserDefaults.standard.synchronize()

            if notify {
                NotificationCenter.default.post(name: Preferences.DidChangeEvent,
                                                object: self,
                                                userInfo: nil)
            }
}
        
        func add(identifier: String, notifyListeners notify: Bool = true) {
            if !self.identifiers.contains(identifier) {
                self.identifiers.append(identifier)
                self.save(notifyListeners: notify)
            }
        }

        func remove(identifier: String, notifyListeners notify: Bool = true) {
            if let index = self.identifiers.firstIndex(of: identifier) {
                self.identifiers.remove(at: index)
                self.save(notifyListeners: notify)
            }
        }

        func set(isIncluded included: Bool, forKey key: String, notifyListeners notify: Bool = true) {
            if included {
                self.add(identifier: key, notifyListeners: notify)
            } else {
                self.remove(identifier: key, notifyListeners: notify)
            }
        }
        
        func removeAll(notifyListeners notify: Bool = true) {
            self.identifiers.removeAll()
            self.save(notifyListeners: notify)
        }
        
        func replaceAll(withIdentifiers newIdentifiers: [String], notifyListeners notify: Bool = true) {
            self.identifiers = newIdentifiers
            self.save(notifyListeners: notify)
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

