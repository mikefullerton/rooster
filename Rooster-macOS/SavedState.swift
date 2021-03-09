//
//  SavedState.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/10/21.
//

import Foundation
import RoosterCore

public class SavedState {
    private var storage: UserDefaults.IdentifierDictionary

    public var firstRunWasPresented: Bool {
        get { self.bool(forKey: .firstRunWasPresented) }
        set { self.setBool(newValue, forKey: .firstRunWasPresented) }
    }

    public var applicationStateVersion: Int {
        get { self.int(forKey: .applicationStateVersion) }
        set { self.setInt(newValue, forKey: .applicationStateVersion) }
    }

    init() {
        self.storage = UserDefaults.IdentifierDictionary(withPreferencesKey: "SavedState")
    }
}

extension SavedState {
    enum SavedStateKey: String, CodingKey {
        case firstRunWasPresented
        case applicationStateVersion
    }

    fileprivate func int(forKey key: SavedStateKey) -> Int {
        if let value = self.storage.value(forKey: key.rawValue) as? Int {
            return value
        }
        return 0
    }

    fileprivate func setInt(_ value: Int, forKey key: SavedStateKey) {
        self.storage.set(value: value, forKey: key.rawValue)
    }

    fileprivate func bool(forKey key: SavedStateKey) -> Bool {
        if let value = self.storage.value(forKey: key.rawValue) as? Bool {
            return value
        }

        return false
    }

    fileprivate func setBool(_ value: Bool, forKey key: SavedStateKey) {
        self.storage.set(value: value, forKey: key.rawValue)
    }
}
