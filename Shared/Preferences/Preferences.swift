//
//  Preferences.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation

struct Preferences : CustomStringConvertible {

    var sounds: SoundPreference
    var useSystemNotifications: Bool
    var systemNotificationDelay: TimeInterval
    var bounceIconInDock: Bool
    var autoOpenLocations: Bool
    
    init(withSounds sounds: SoundPreference,
         useSystemNotifications: Bool,
         systemNotificationDelay: TimeInterval,
         bounceIconInDock: Bool,
         autoOpenLocations: Bool) {
        
        self.sounds = sounds
        self.useSystemNotifications = useSystemNotifications
        self.bounceIconInDock = bounceIconInDock
        self.autoOpenLocations = autoOpenLocations
        self.systemNotificationDelay = systemNotificationDelay
    }
    
    var description: String {
        return "Prefs: useSystemNotifications: \(self.useSystemNotifications), bounce icon: \(self.bounceIconInDock), auto open Locaitions: \(self.autoOpenLocations)"
    }
    
}
