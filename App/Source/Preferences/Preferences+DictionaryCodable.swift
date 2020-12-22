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
    }
    
    init?(withDictionary dictionary: [AnyHashable : Any]) {
        
        if let soundsDictionary = dictionary[CodingKeys.sounds.rawValue] as? [AnyHashable: Any] {
            self.sounds = SoundPreference(withDictionary: soundsDictionary) ?? SoundPreference()
        } else {
            self.sounds = SoundPreference()
        }
        
        if let useSystemNotifications = dictionary[CodingKeys.useSystemNotifications.rawValue] as? Bool {
            self.useSystemNotifications = useSystemNotifications
        } else {
            self.useSystemNotifications = false
        }

        if let bounceIconInDock = dictionary[CodingKeys.bounceIconInDock.rawValue] as? Bool {
            self.bounceIconInDock = bounceIconInDock
        } else {
            self.bounceIconInDock = false
        }
        
        if let autoOpenLocations = dictionary[CodingKeys.autoOpenLocations.rawValue] as? Bool {
            self.autoOpenLocations = autoOpenLocations
        } else {
            self.autoOpenLocations = false
        }
    }

    var asDictionary: [AnyHashable : Any] {
        var dictionary: [AnyHashable : Any] = [:]
        dictionary[CodingKeys.sounds.rawValue] = self.sounds.asDictionary
        dictionary[CodingKeys.useSystemNotifications.rawValue] = self.useSystemNotifications
        dictionary[CodingKeys.bounceIconInDock.rawValue] = self.bounceIconInDock
        dictionary[CodingKeys.autoOpenLocations.rawValue] = self.autoOpenLocations
        return dictionary
    }
}

extension SoundPreference {
    
    enum CodingKeys: String, CodingKey {
        case sounds = "sounds"
        case repeatCount = "repeatCount"
    }
    
    init?(withDictionary dictionary: [AnyHashable : Any]) {
    
        if let sounds = dictionary[CodingKeys.sounds.rawValue] as? [String] {
            self.sounds = sounds
        } else {
            self.sounds = []
        }
        
        if let repeatCount = dictionary[CodingKeys.repeatCount.rawValue] as? Int {
            self.repeatCount = repeatCount
        } else {
            self.repeatCount = -1
        }
    }

    var asDictionary: [AnyHashable : Any] {
        var dictionary: [AnyHashable : Any] = [:]
        dictionary[CodingKeys.sounds.rawValue] = self.sounds
        dictionary[CodingKeys.repeatCount.rawValue] = self.repeatCount
        return dictionary
    }

}
