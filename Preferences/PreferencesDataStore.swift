//
//  Preferences.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation

struct PreferencesDataStore {
 
    
//    let sounds: IdentifierDictionary
    

    init() {
    }
    
    func setBool(_ value: Bool, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func bool(forKey key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
}

