//
//  SingleSoundPreference.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/3/21.
//

import Foundation
import RoosterCore

public struct SingleSoundPreference : CustomStringConvertible, Equatable, Identifiable, Codable {

    public typealias ID = String
    
    public let id: ID
    public var soundSet: SoundSet
    public var isEnabled: Bool
    
    public var description: String {
        return """
        \(type(of:self)): \
        id: \(self.id), \
        SoundSet: \(self.soundSet.description), \
        enabled: \(self.isEnabled)
        """
    }

    public init(withIdentifier id: String,
                soundSet: SoundSet,
                enabled: Bool) {
        
        self.id = id
        self.soundSet = soundSet
        self.isEnabled = enabled
    }
}

extension SingleSoundPreference {

    public static var random: SingleSoundPreference {
        return SingleSoundPreference(withIdentifier: SoundSet.random.id, soundSet: SoundSet.random, enabled: true)
    }

    public static var empty: SingleSoundPreference {
        return SingleSoundPreference(withIdentifier: SoundSet.empty.id, soundSet: SoundSet.empty, enabled: true)
    }

    public static var zero: SingleSoundPreference {
        return SingleSoundPreference(withIdentifier: "zero", soundSet: SoundSet.empty, enabled: false)
    }
}
