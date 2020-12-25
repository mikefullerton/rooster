//
//  SoundPreferences+DictionaryCodable.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/25/20.
//

import Foundation

extension SoundPreference {
    
    enum CodingKeys: String, CodingKey {
        case sounds = "sounds"
        case playCount = "playCount"
        case startDelay = "startDelay"
    }
    
    init?(withDictionary dictionary: [AnyHashable : Any]) {
    
        if let sounds = dictionary[CodingKeys.sounds.rawValue] as? [String] {
            self.soundNames = sounds
        } else {
            self.soundNames = []
        }
        
        if let playCount = dictionary[CodingKeys.playCount.rawValue] as? Int {
            self.playCount = playCount
        } else {
            self.playCount = 0
        }

        if let startDelay = dictionary[CodingKeys.startDelay.rawValue] as? Int {
            self.startDelay = startDelay
        } else {
            self.startDelay = 0
        }
    }

    var asDictionary: [AnyHashable : Any] {
        var dictionary: [AnyHashable : Any] = [:]
        dictionary[CodingKeys.sounds.rawValue] = self.soundNames
        dictionary[CodingKeys.playCount.rawValue] = self.playCount
        dictionary[CodingKeys.startDelay.rawValue] = self.startDelay
        return dictionary
    }

}
