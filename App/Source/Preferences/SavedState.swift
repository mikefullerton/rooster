//
//  SavedState.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/10/21.
//

import Foundation

struct SavedState {
    
    enum SavedStateKey: String, CodingKey {
        case lookedForCalendarOnFirstRun = "lookedForCalendarOnFirstRun"
        case firstRunWasPresented = "firstRunWasPresented"
    }
    
    private var storage: UserDefaults.IdentifierDictionary
    
    init() {
        self.storage = UserDefaults.IdentifierDictionary(withPreferencesKey: "SavedState")
    }

    func bool(forKey key: SavedStateKey) -> Bool {
        if let value = self.storage.value(forKey: key.rawValue) as? Bool {
            return value
        }
        
        return false
    }
    
    mutating func setBool(_ value: Bool, forKey key: SavedStateKey) {
        self.storage.set(value: value, forKey: key.rawValue)
    }
}
