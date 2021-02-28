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
    
    public var soundSet: SoundSet {
        didSet { self.updateTimestamp() }
    }
    
    public var isEnabled: Bool {
        didSet { self.updateTimestamp() }
    }
    
    private var timestamp: Date
    
    private mutating func updateTimestamp() {
        self.timestamp = Date()
    }
    
    public var description: String {
        return """
        \(type(of:self)): \
        id: \(self.id), \
        SoundSet: \(self.soundSet.description), \
        enabled: \(self.isEnabled), \
        timestamp: \(self.timestamp.shortDateAndLongTimeString)
        """
    }

    public init(withIdentifier id: String,
                soundSet: SoundSet,
                enabled: Bool) {
        
        self.timestamp = Date()
        self.id = id
        self.soundSet = soundSet
        self.isEnabled = enabled
    }

    public static func == (lhs: SingleSoundPreference, rhs: SingleSoundPreference) -> Bool {
        return  lhs.id == rhs.id &&
                lhs.soundSet == rhs.soundSet &&
                lhs.isEnabled == rhs.isEnabled
    }
    
//    public static func singleSoundPref(withSoundFileCollection soundFileCollection: SoundFileCollection) -> SingleSoundPreference {
//
//        let id = String.guid
//        
//        let soundSet = SoundSet(withID: id,
//                                url: nil,
//                                displayName: "",
//                                randomizer: PlayListRandomizer.none,
//                                soundFileCollection: soundFileCollection,
//                                soundFolder: SoundFolder.instance)
//        
//        return SingleSoundPreference(withIdentifier: id, soundSet: soundSet, enabled: true)
//    }
    
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
