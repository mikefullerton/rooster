//
//  Preferences.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation

struct Preferences : CustomStringConvertible, Loggable {

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
        return "Prefs: notification: \(self.notificationPreferences.description), sounds: \(self.soundPreferences.description), menuBar: \(self.menuBarPreferences.description)"
    }
}


extension Preferences : DictionaryCodable {
 
    enum CodingKeys: String, CodingKey {
        case version = "version"
        case sounds = "sounds"
        case notifications = "notifications"
        case menuBar = "menuBar"
    }
    
    init(withDictionary dictionary: [AnyHashable : Any]) {
        
        self.init()
        
        guard let version = dictionary[CodingKeys.version.rawValue] as? Int,
              version == Self.version else {
            
            self.logger.log("Unexpected or invalid prefereces version, expecting: \(Self.version). Reset to defaults.")
            
            return
        }
        
        if let dictionary = dictionary[CodingKeys.sounds.rawValue] as? [AnyHashable: Any] {
            self.soundPreferences = SoundPreferences(withDictionary: dictionary)
        }
        
        if let dictionary = dictionary[CodingKeys.notifications.rawValue] as? [AnyHashable: Any] {
            self.notificationPreferences = NotificationPreferences(withDictionary: dictionary)
        }
        
        if let dictionary = dictionary[CodingKeys.menuBar.rawValue] as? [AnyHashable: Any] {
            self.menuBarPreferences = MenuBarPreferences(withDictionary: dictionary)
        }
    }

    var dictionaryRepresentation: [AnyHashable : Any] {
        var dictionary: [AnyHashable : Any] = [:]
        
        dictionary[CodingKeys.version.rawValue] = Self.version
        dictionary[CodingKeys.sounds.rawValue] = self.soundPreferences.asDictionary
        dictionary[CodingKeys.notifications.rawValue] = self.notificationPreferences.asDictionary
        dictionary[CodingKeys.menuBar.rawValue] = self.menuBarPreferences.asDictionary

        return dictionary
    }
}

