//
//  Preferences+DictionaryCodable.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation

extension Preferences : DictionaryCodable {
 
    enum CodingKeys: String, CodingKey {
        case sounds = "sounds"
        case useSystemNotifications = "useSystemNotifications"
        case bounceIconInDock = "bounceIconInDock"
        case autoOpenLocations = "autoOpenLocations"
        case systemNotificationDelay = "systemNotificationDelay"
    }
    
    init?(withDictionary dictionary: [AnyHashable : Any]) {
        
        self.init()
        
        if let soundsDictionary = dictionary[CodingKeys.sounds.rawValue] as? [AnyHashable: Any] {
            self.sounds = SoundPreference(withDictionary: soundsDictionary) ?? SoundPreference()
        }
        
        if let useSystemNotifications = dictionary[CodingKeys.useSystemNotifications.rawValue] as? Bool {
            self.useSystemNotifications = useSystemNotifications
        }

        if let bounceIconInDock = dictionary[CodingKeys.bounceIconInDock.rawValue] as? Bool {
            self.bounceIconInDock = bounceIconInDock
        }
        
        if let autoOpenLocations = dictionary[CodingKeys.autoOpenLocations.rawValue] as? Bool {
            self.autoOpenLocations = autoOpenLocations
        }
        
        if let autoOpenLocations = dictionary[CodingKeys.autoOpenLocations.rawValue] as? Bool {
            self.autoOpenLocations = autoOpenLocations
        }
        
        if let systemNotificationDelay = dictionary[CodingKeys.systemNotificationDelay.rawValue] as? TimeInterval {
            self.systemNotificationDelay = systemNotificationDelay
        }
    }

    var dictionaryRepresentation: [AnyHashable : Any] {
        var dictionary: [AnyHashable : Any] = [:]
        dictionary[CodingKeys.sounds.rawValue] = self.sounds.asDictionary
        dictionary[CodingKeys.useSystemNotifications.rawValue] = self.useSystemNotifications
        dictionary[CodingKeys.bounceIconInDock.rawValue] = self.bounceIconInDock
        dictionary[CodingKeys.autoOpenLocations.rawValue] = self.autoOpenLocations
        dictionary[CodingKeys.systemNotificationDelay.rawValue] = self.systemNotificationDelay
        return dictionary
    }
}

