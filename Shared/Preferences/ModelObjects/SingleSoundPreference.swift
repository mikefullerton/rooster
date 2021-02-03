//
//  SingleSoundPreference.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/3/21.
//

import Foundation

struct SingleSoundPreference : CustomStringConvertible {
    
    let soundIdentifier: String
    let isRandom: Bool
    var isEnabled: Bool
    
    private init(soundIdentifier: String,
         enabled: Bool,
         random: Bool) {
        
        self.soundIdentifier = soundIdentifier
        self.isRandom = random
        self.isEnabled = enabled
    }

    init(soundIdentifier identifier: String,
         enabled: Bool) {

        self.init(soundIdentifier: identifier, enabled: enabled, random: false)
    }
        
    var description: String {
        return "Sound: \(self.soundIdentifier), enabled: \(self.isEnabled), random: \(self.isRandom)"
    }

    static func random() -> SingleSoundPreference {
        return SingleSoundPreference(soundIdentifier: "",
                                     enabled: true,
                                     random: true)
    }
    
    var isEmpty: Bool {
        return self.soundIdentifier == "" && self.isRandom == false
    }
    
    static let zero = SingleSoundPreference(soundIdentifier: "", enabled: false)
    static let default1 = SingleSoundPreference(soundIdentifier: "Sounds/Animals/Rooster Crowing", enabled: true)
    static let default2 = SingleSoundPreference.zero
    static let default3 = SingleSoundPreference.zero
}

extension SingleSoundPreference {
    enum CodingKeys: String, CodingKey {
        case identifier = "identifier"
        case enabled = "enabled"
        case random = "random"
    }
    
    init?(withDictionary dictionary: [AnyHashable : Any]) {
        
        var enabled:Bool? = nil
        var random:Bool? = false
        var soundIdentifier:String? = nil
        
        if let randomValue = dictionary[CodingKeys.random.rawValue] as? Bool {
            random = randomValue
        }

        if let soundIdentifierValue = dictionary[CodingKeys.identifier.rawValue] as? String {
            soundIdentifier = soundIdentifierValue
        }
        
        if let enabledValue = dictionary[CodingKeys.enabled.rawValue] as? Bool {
            enabled = enabledValue
        }
        
        guard enabled != nil,
              random != nil,
              soundIdentifier != nil else {
            return nil
        }
        
        if random! == true {
            soundIdentifier = SoundFolder.instance.randomSound.identifier
        }
        
        self.init(soundIdentifier: soundIdentifier!, enabled: enabled!, random:random!)
    }

    var asDictionary: [AnyHashable : Any] {
        var dictionary: [AnyHashable : Any] = [:]
        dictionary[CodingKeys.identifier.rawValue] = self.soundIdentifier
        dictionary[CodingKeys.enabled.rawValue] = self.isEnabled
        dictionary[CodingKeys.random.rawValue] = self.isRandom
        return dictionary
    }
}

