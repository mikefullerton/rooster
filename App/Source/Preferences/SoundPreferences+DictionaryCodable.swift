//
//  SoundPreferences+DictionaryCodable.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/25/20.
//

import Foundation

extension SoundPreference.Sound {
    enum CodingKeys: String, CodingKey {
        case url = "name"
        case enabled = "enabled"
        case random = "random"
    }
    
    init?(withDictionary dictionary: [AnyHashable : Any]) {
    
        self.url = URL(string:"")
        self.enabled = false
        self.random = false

        if let enabled = dictionary[CodingKeys.enabled.rawValue] as? Bool {
            self.enabled = enabled
        }
        
        if let random = dictionary[CodingKeys.random.rawValue] as? Bool {
            self.random = random
        }

        if let urlString = dictionary[CodingKeys.url.rawValue] as? String,
           urlString.count > 0 {
            self.url = URL(string: urlString)
        } else {
            self.enabled = false
        }
        
    }

    var asDictionary: [AnyHashable : Any] {
        var dictionary: [AnyHashable : Any] = [:]
        dictionary[CodingKeys.url.rawValue] = self.url?.absoluteString ?? ""
        dictionary[CodingKeys.enabled.rawValue] = self.enabled
        dictionary[CodingKeys.random.rawValue] = self.random
        return dictionary
    }
}

extension SoundPreference {
    
    enum CodingKeys: String, CodingKey {
        case sounds = "sounds"
        case playCount = "playCount"
        case startDelay = "startDelay"
    }
    
    init?(withDictionary dictionary: [AnyHashable : Any]) {
    
        self.init()
        
        if let sounds = dictionary[CodingKeys.sounds.rawValue] as? [[AnyHashable: Any]] {
            for (index, soundDictionary) in sounds.enumerated() {
                
                if let sound = Sound(withDictionary: soundDictionary),
                   let soundIndex = SoundIndex(rawValue: index) {
                    self[soundIndex] = sound
                }
            }
        }
        
        if let playCount = dictionary[CodingKeys.playCount.rawValue] as? Int {
            self.playCount = playCount
        }
        
        if let startDelay = dictionary[CodingKeys.startDelay.rawValue] as? Int {
            self.startDelay = startDelay
        }
    }

    var asDictionary: [AnyHashable : Any] {
        var dictionary: [AnyHashable : Any] = [:]
        dictionary[CodingKeys.sounds.rawValue] = self.sounds.map { $0.asDictionary }
        dictionary[CodingKeys.playCount.rawValue] = self.playCount
        dictionary[CodingKeys.startDelay.rawValue] = self.startDelay
        return dictionary
    }

}
