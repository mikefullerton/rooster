//
//  PreferencesDataStore+IdentifierDictionary.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation

extension PreferencesDataStore {
    
    struct IdentifierDictionary {
        private let preferencesKey: String
        
        init(withPreferencesKey key: String) {
            self.preferencesKey = key
        }

        private func save(_ dictionary:[AnyHashable: Any]) {
            UserDefaults.standard.set(dictionary, forKey: self.preferencesKey)
            UserDefaults.standard.synchronize()
        }
        
        func set(value: Any?, forKey key: String) {
            
            var dictionary = self.dictionary
            
            if value != nil {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
            
            self.save(dictionary)
        }
        
        func value(forKey key: String) -> Any? {
            return self.dictionary[key]
        }
        
        func removeValue(forKey key: String) {
            var dictionary = self.dictionary
            dictionary.removeValue(forKey: key)
            self.save(dictionary)
        }

        func removeAll() {
            self.save([:])
        }
        
        func replaceAll(_ dictionary: [AnyHashable: Any]) {
            self.save(dictionary)
        }
        
        var dictionary: [AnyHashable: Any] {
            get {
                return UserDefaults.standard.dictionary(forKey: self.preferencesKey) ?? [:]
            }
            set(newDictionary) {
                self.replaceAll(newDictionary)
            }
        }
    }
}
