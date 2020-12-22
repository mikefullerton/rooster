//
//  Preferences.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation

struct SoundPreference {
    let sounds: [String]
    let repeatCount: Int
    
    init(withSounds sounds: [String],
         repeatCount: Int) {
        self.sounds = sounds
        self.repeatCount = repeatCount
    }
    
    init() {
        self.init(withSounds: [], repeatCount: -1)
    }
}

struct Preferences {

    let sounds: SoundPreference
    let useSystemNotifications: Bool
    let bounceIconInDock: Bool
    let autoOpenLocations: Bool
    
    init(withSounds sounds: SoundPreference,
         useSystemNotifications: Bool,
         bounceIconInDock: Bool,
         autoOpenLocations: Bool) {
        
        self.sounds = sounds
        self.useSystemNotifications = useSystemNotifications
        self.bounceIconInDock = bounceIconInDock
        self.autoOpenLocations = autoOpenLocations
    }
    
    init() {
        self.init(withSounds: SoundPreference(),
                  useSystemNotifications: false,
                  bounceIconInDock: false,
                  autoOpenLocations: false)
    }
}
