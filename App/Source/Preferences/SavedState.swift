//
//  SavedState.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/10/21.
//

import Foundation

struct SavedState {
    
    enum Keys: String, CodingKey {
        case lookedForCalendarOnFirstRun = "lookedForCalendarOnFirstRun"
    }
    
    private var storage: UserDefaults.IdentifierDictionary
    
    init() {
        self.storage = UserDefaults.IdentifierDictionary(withPreferencesKey: "SavedState")
    }
    
    var lookedForCalendarOnFirstRun: Bool {
        get {
            if let value = self.storage.value(forKey: Keys.lookedForCalendarOnFirstRun.rawValue) as? Bool {
                return value
            }
            
            return false
        }
        set(value) {
            self.storage.set(value: value, forKey: Keys.lookedForCalendarOnFirstRun.rawValue)
        }
    }
    
}
