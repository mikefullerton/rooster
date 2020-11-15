//
//  Preferences.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation

struct Preferences {
    
    static let PreferencesDidChangeEvent = Notification.Name(rawValue: "PreferencesDidChangeEvent")

    struct IdentifierList {
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
        
        mutating func add(identifier: String) {
            self.identifiers.append(identifier)
            self.save()
        }

        mutating func remove(identifier: String) {
            if let index = self.identifiers.firstIndex(of: identifier) {
                self.identifiers.remove(at: index)
                self.save()
            }
        }

        mutating func removeAll() {
            self.identifiers.removeAll()
            self.save()
        }
    }
    
    
    let calendarIdentifers: IdentifierList
    let unsubscribedEvents: IdentifierList
    let unsubscribedReminders: IdentifierList
    
    static var instance = Preferences()
    
    init() {
        self.calendarIdentifers = IdentifierList(withPreferencesKey: "calendars")
        self.unsubscribedEvents = IdentifierList(withPreferencesKey: "events")
        self.unsubscribedReminders = IdentifierList(withPreferencesKey: "reminders")
    }
    
    
    
    
    
}

