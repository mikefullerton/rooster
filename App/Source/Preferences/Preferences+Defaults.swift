//
//  Prefernces+Defaults.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/25/20.
//

import Foundation

extension SoundPreference {
    init() {
        self.init(sound1: Sound(name: "Rooster Crowing", enabled: true, random: false),
                  sound2: Sound(name: "Chickens", enabled: true, random: false),
                  sound3: Sound(name: "Rooster Crowing", enabled: true, random: false),
                  playCount: SoundPreference.RepeatEndlessly,
                  startDelay: 3)
    }
}

extension Preferences {
    init() {
        self.init(withSounds: SoundPreference(),
                  useSystemNotifications: true,
                  systemNotificationDelay: 7,
                  bounceIconInDock: true,
                  autoOpenLocations: true)
    }
}

extension ItemPreference {
    init() {
        self.soundPreference = SoundPreference()
    }
}
