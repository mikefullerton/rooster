//
//  ItemPreference.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation

struct ItemPreference {
    var soundPreference: SoundPreferences
    
    init(with soundPreferences: SoundPreferences) {
        self.soundPreference = soundPreferences
    }
    
    init() {
        self.init(with: SoundPreferences())
    }
}
