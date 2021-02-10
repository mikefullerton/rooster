//
//  SingleSoundPreference.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/3/21.
//

import Foundation

struct SingleSoundPreference : CustomStringConvertible, Equatable, Identifiable, Codable {
    
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
        return SingleSoundPreference(withIdentifier: id,
                                     soundSet: SoundSet.random,
                                     enabled: true)
    }
    
    var isSoundSetEmpty: Bool {
        return self.soundSet.soundFolder.soundCount == 0
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
