//
//  PreferencesStorage.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/8/21.
//

import Foundation
import RoosterCore

protocol PreferencesStorage {
    func read() throws -> Preferences?
    func write(_ preferences: Preferences) throws
    func delete() throws
}

