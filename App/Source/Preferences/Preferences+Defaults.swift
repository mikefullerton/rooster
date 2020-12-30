//
//  Prefernces+Defaults.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/25/20.
//

import Foundation

extension SoundPreference {
    init() {
        if let defaultURL = SoundPreference.urlForName("Rooster Crowing") {
            self.init(sound1: Sound(url: defaultURL, enabled: true, random: false),
                      sound2: Sound.zero,
                      sound3: Sound.zero,
                      playCount: SoundPreference.RepeatEndlessly,
                      startDelay: 3,
                      volume: 1.0)
            return
        }
        
        self.init(sound1: Sound.zero,
                  sound2: Sound.zero,
                  sound3: Sound.zero,
                  playCount: SoundPreference.RepeatEndlessly,
                  startDelay: 3,
                  volume: 1.0)
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
