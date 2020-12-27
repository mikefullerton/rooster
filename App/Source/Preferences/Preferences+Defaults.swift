//
//  Prefernces+Defaults.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/25/20.
//

import Foundation

extension SoundPreference {
    
    static var defaults: SoundPreference {
        return SoundPreference(withSoundNames: [ "Rooster Crowing", "Chickens", "Rooster Crowing" ],
                                              playCount: SoundPreference.RepeatEndlessly,
                                              startDelay: 3)
    }
}

extension Preferences {
    static var defaults: Preferences {
        return Preferences(withSounds: SoundPreference.defaults,
                           useSystemNotifications: true,
                           bounceIconInDock: true,
                           autoOpenLocations: true)
    }
}

extension ItemPreference {
    
    static var defaults: ItemPreference {
        return ItemPreference(soundPreference: SoundPreference.defaults)
    }
}
