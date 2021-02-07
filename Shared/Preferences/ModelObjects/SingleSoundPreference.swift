//
//  SingleSoundPreference.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/3/21.
//

import Foundation

struct SingleSoundPreference : CustomStringConvertible, Equatable, Identifiable {
    
    typealias ID = String
    
    let id: ID
    var soundSet: SoundSet
    var isEnabled: Bool
    
    static let AnySoundIdentifier = "*"
    
    init(withIdentifier id: String,
         soundSet: SoundSet,
         enabled: Bool) {
        
        self.id = id
        self.soundSet = soundSet
        self.isEnabled = enabled
    }
  
    var description: String {
        return "\(type(of:self)): id: \(self.id), SoundSet: \(self.soundSet.description), enabled: \(self.isEnabled)"
    }

    static func anyRandomSound(withID id: String, name: String) -> SingleSoundPreference {
        
        let soundIdentifier = SoundFileDescriptor(with: SoundFileDescriptor.AnySoundIdentifier,
                                              randomizerPriority: .normal)
        
        let soundSet = SoundSet(withIdentifier: id,
                                name: name,
                                soundIdentifiers: [ soundIdentifier ])
        
        return SingleSoundPreference(withIdentifier: id,
                                     soundSet: soundSet,
                                     enabled: true)
    }
    
    var isSoundSetEmpty: Bool {
        return self.soundSet.isEmpty
    }
    
    static func == (lhs: SingleSoundPreference, rhs: SingleSoundPreference) -> Bool {
        return  lhs.soundSet == rhs.soundSet &&
                lhs.isEnabled == rhs.isEnabled
    }
    
    static let zero = SingleSoundPreference(withIdentifier: "zero", soundSet: SoundSet.empty, enabled: false)
    
    static let default1 = SingleSoundPreference(withIdentifier: "default", soundSet: SoundSet.default, enabled: true)
    static let default2 = SingleSoundPreference.zero
    static let default3 = SingleSoundPreference.zero
    
    var isRandom: Bool {
        get {
            return self.soundSet.isRandom
        }
        set(isRandom) {
            self.soundSet = SoundSet.random
        }
    }
    
    static var random: SingleSoundPreference {
        return SingleSoundPreference(withIdentifier: "Random", soundSet: SoundSet.random, enabled: true)
    }
    
}

extension SingleSoundPreference {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case enabled = "enabled"
        case soundSet = "random"
    }
    
    init?(withDictionary dictionary: [AnyHashable : Any]) {
        
        
        if let id = dictionary[CodingKeys.id.rawValue] as? String,
            let enabled = dictionary[CodingKeys.enabled.rawValue] as? Bool,
            let soundSetDictionary = dictionary[CodingKeys.soundSet.rawValue] as? [AnyHashable: Any],
            let soundSet = SoundSet(withDictionary: soundSetDictionary) {
            
            self.init(withIdentifier: id, soundSet: soundSet, enabled: enabled)
        }
        
        return nil
    }

    var asDictionary: [AnyHashable : Any] {
        var dictionary: [AnyHashable : Any] = [:]
        dictionary[CodingKeys.id.rawValue] = self.id
        dictionary[CodingKeys.enabled.rawValue] = self.isEnabled
        dictionary[CodingKeys.soundSet.rawValue] = self.soundSet.asDictionary
        return dictionary
    }
}

