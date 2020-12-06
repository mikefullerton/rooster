//
//  PrefencesDataStore+IdentifierList.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation

extension PreferencesDataStore {
    struct IdentifierList {
        private let preferencesKey: String
        
        init(withPreferencesKey key: String) {
            self.preferencesKey = key
        }

        private func save(_ list: [String]) {
            UserDefaults.standard.set(list, forKey: self.preferencesKey)
            UserDefaults.standard.synchronize()
        }
        
        func add(identifier: String) {
            var list = self.identifiers
            
            if !list.contains(identifier) {
                list.append(identifier)
                self.save(list)
            }
        }

        func remove(identifier: String) {
            var list = self.identifiers
            
            if let index = list.firstIndex(of: identifier) {
                list.remove(at: index)
                self.save(list)
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
            self.save([])
        }
        
        func replaceAll(withIdentifiers newIdentifiers: [String]) {
            self.save(newIdentifiers)
        }
        
        func contains(_ id: String) -> Bool {
            return self.identifiers.contains(id)
        }
        
        var identifiers:[String] {
            get {
                return UserDefaults.standard.stringArray(forKey: preferencesKey) ?? []
            }
            set(newList) {
                self.replaceAll(withIdentifiers: newList)
            }
        }
    }
}
