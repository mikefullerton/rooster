//
//  Preferences.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation
import RoosterCore

struct Preferences : CustomStringConvertible, Loggable, Codable {

    static let version = 2
    
    var soundPreferences: SoundPreferences
    var notificationPreferences: NotificationPreferences
    var menuBarPreferences: MenuBarPreferences
    
    init(withSoundPreferences soundPreferences: SoundPreferences,
         notificationPreferences: NotificationPreferences,
         menuBarPreferences: MenuBarPreferences) {
        
        self.soundPreferences = soundPreferences
        self.notificationPreferences = notificationPreferences
        self.menuBarPreferences = menuBarPreferences
    }
    
    init() {
        self.init(withSoundPreferences: SoundPreferences(),
                  notificationPreferences: NotificationPreferences(),
                  menuBarPreferences: MenuBarPreferences())
    }

    var description: String {
        return "\(type(of:self)): notification: \(self.notificationPreferences.description), sounds: \(self.soundPreferences.description), menuBar: \(self.menuBarPreferences.description)"
    }
}

