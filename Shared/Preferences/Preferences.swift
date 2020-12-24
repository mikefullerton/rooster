//
//  Preferences.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation

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
                  useSystemNotifications: true,
                  bounceIconInDock: true,
                  autoOpenLocations: true)
    }
}
