//
//  ItemPreference.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation
import RoosterCore

public struct ItemPreference {
    public var soundPreference: SoundPreferences
    
    public init(with soundPreferences: SoundPreferences) {
        self.soundPreference = soundPreferences
    }
    
    public init() {
        self.init(with: SoundPreferences.default)
    }
}
