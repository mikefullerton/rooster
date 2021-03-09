//
//  PrefencesDataStore+IdentifierList.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation

extension UserDefaults {
    public struct IdentifierList {
        private let preferencesKey: String

        public init(withPreferencesKey key: String) {
            self.preferencesKey = key
        }

        private func save(_ list: [String]) {
            UserDefaults.standard.set(list, forKey: self.preferencesKey)
            UserDefaults.standard.synchronize()
        }

        public func add(identifier: String) {
            var list = self.identifiers

            if !list.contains(identifier) {
                list.append(identifier)
                self.save(list)
            }
        }

        public func remove(identifier: String) {
            var list = self.identifiers

            if let index = list.firstIndex(of: identifier) {
                list.remove(at: index)
                self.save(list)
            }
        }

        public func set(isIncluded included: Bool, forKey key: String) {
            if included {
                self.add(identifier: key)
            } else {
                self.remove(identifier: key)
            }
        }

        public func removeAll() {
            self.save([])
        }

        public func replaceAll(withIdentifiers newIdentifiers: [String]) {
            self.save(newIdentifiers)
        }

        public func contains(_ id: String) -> Bool {
            self.identifiers.contains(id)
        }

        public var identifiers: [String] {
            get {
                UserDefaults.standard.stringArray(forKey: preferencesKey) ?? []
            }
            set(newList) {
                self.replaceAll(withIdentifiers: newList)
            }
        }
    }
}
