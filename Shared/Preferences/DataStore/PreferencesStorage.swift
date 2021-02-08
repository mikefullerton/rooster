//
//  PreferencesStorage.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/8/21.
//

import Foundation

protocol PreferencesStorage {
    func read() throws -> [AnyHashable: Any]?
    func write(_ preferences: [AnyHashable: Any]) throws
    func delete() throws
}

