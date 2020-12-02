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
        
        func removeAll() {
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
    
    class IdentifierDictionary {
        private let preferencesKey: String
        private var dictionary: [String: Any]

        init(withPreferencesKey key: String) {
            self.preferencesKey = key
            self.dictionary = UserDefaults.standard.dictionary(forKey: key) ?? [:]
        }

        private func save() {
//            if let oldDictionary = UserDefaults.standard.dictionary(forKey: self.preferencesKey) {
////               if self.dictionary == oldDictionary {
////                    return
////               }
//            }

            UserDefaults.standard.set(self.dictionary, forKey: self.preferencesKey)
            UserDefaults.standard.synchronize()
        }
        
        func set(value: Any?, forKey key: String) {
            
            if value != nil {
                self.dictionary[key] = value
            } else {
                self.dictionary.removeValue(forKey: key)
            }
            
            self.save()
        }
        
        func value(forKey key: String) -> Any? {
            return self.dictionary[key]
        }
        
        func removeValue(forKey key: String) {
            self.dictionary.removeValue(forKey: key)
            self.save()
        }

        func removeAll() {
            self.dictionary.removeAll()
            self.save()
        }
        
        func replaceAll(with dictionary: [String: Any]) {
            self.dictionary = dictionary
            self.save()
        }
    }
    
    let subscribedCalendars: IdentifierList

    let unsubscribedEvents: IdentifierList
    
    let unsubscribedReminders: IdentifierList

    let alarmStates: IdentifierDictionary
    
    init() {
        self.subscribedCalendars = IdentifierList(withPreferencesKey: "calendars")
        self.unsubscribedEvents = IdentifierList(withPreferencesKey: "events")
        self.unsubscribedReminders = IdentifierList(withPreferencesKey: "reminders")
        self.alarmStates = IdentifierDictionary(withPreferencesKey: "alarm-states")
    }
}

