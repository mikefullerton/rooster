//
//  Preferences.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation

class Preferences {
    
    static let PreferencesDidChangeEvent = Notification.Name(rawValue: "PreferencesDidChangeEvent")

    class IdentifierList {
        private let preferencesKey: String
        
        var identifiers: [String]

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

            NotificationCenter.default.post(name: Preferences.PreferencesDidChangeEvent,
                                            object: self,
                                            userInfo: nil)

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
        
        func removeAll() {
            self.identifiers.removeAll()
            self.save()
        }
    }
    
    let calendarIdentifers: IdentifierList
    let unsubscribedEvents: IdentifierList
    let unsubscribedReminders: IdentifierList
    
    init() {
        self.calendarIdentifers = IdentifierList(withPreferencesKey: "calendars")
        self.unsubscribedEvents = IdentifierList(withPreferencesKey: "events")
        self.unsubscribedReminders = IdentifierList(withPreferencesKey: "reminders")
    }
    
    
    
    
    
}

