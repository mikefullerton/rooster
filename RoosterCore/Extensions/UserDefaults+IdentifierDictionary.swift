//
//  PreferencesDataStore+IdentifierDictionary.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation

extension UserDefaults {
    public struct IdentifierDictionary {
        private let preferencesKey: String

        public init(withPreferencesKey key: String) {
            self.preferencesKey = key
        }

        private func save(_ dictionary: [AnyHashable: Any]) {
            UserDefaults.standard.set(dictionary, forKey: self.preferencesKey)
            UserDefaults.standard.synchronize()
        }

        public func set(value: Any?, forKey key: String) {
            if var dictionary = self.dictionary {
                if value != nil {
                    dictionary[key] = value
                } else {
                    dictionary.removeValue(forKey: key)
                }

                self.save(dictionary)
            } else if value != nil {
                self.save([key: value!])
            }
        }

        public func value(forKey key: String) -> Any? {
            if let dictionary = self.dictionary {
                return dictionary[key]
            }

            return nil
        }

        public func removeValue(forKey key: String) {
            if var dictionary = self.dictionary {
                dictionary.removeValue(forKey: key)
                self.save(dictionary)
            }
        }

        public func removeAll() {
            self.save([:])
        }

        public func replaceAll(_ dictionary: [AnyHashable: Any]?) {
            if dictionary != nil {
                self.save(dictionary!)
            } else {
                self.removeAll()
            }
        }

        public var dictionary: [AnyHashable: Any]? {
            get {
                UserDefaults.standard.dictionary(forKey: self.preferencesKey)
            }
            set(newDictionary) {
                self.replaceAll(newDictionary)
            }
        }
    }
}
