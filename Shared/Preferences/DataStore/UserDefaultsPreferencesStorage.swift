//
//  UserDefaultsPreferencesStorage.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/8/21.
//

import Foundation

class UserDefaultsPreferencesStorage : PreferencesStorage {
    
    private var storage: UserDefaults.IdentifierDictionary
 
    init() {
        self.storage = UserDefaults.IdentifierDictionary(withPreferencesKey: "preferences")
    }
        
    func read() throws -> [AnyHashable: Any]?  {
        return self.storage.dictionary
    }
    
    func write(_ dictionary: [AnyHashable: Any]) throws {
        self.storage.dictionary = dictionary
    }
    
    func delete() {
        self.storage.dictionary = nil
    }
}
