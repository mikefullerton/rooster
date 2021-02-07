//
//  SoundPreference.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation

struct SoundPreferences: Sequence, CustomStringConvertible, Equatable {
    
    
    typealias Element = SingleSoundPreference
    typealias Iterator = Array<SingleSoundPreference>.Iterator
    
    static let RepeatEndlessly = AlarmSoundBehavior.RepeatEndlessly

    enum SoundIndex : Int {
        case sound1
        case sound2
        case sound3
    }

    private(set) var sounds: [SingleSoundPreference]
    
    var playCount: Int
    var startDelay: Int
    var volume:Float
    
    init(sound1: SingleSoundPreference,
         sound2: SingleSoundPreference,
         sound3: SingleSoundPreference,
         playCount: Int,
         startDelay: Int,
         volume: Float) {
        
        self.sounds = [
            sound1,
            sound2,
            sound3
        ]
        
        self.playCount = playCount
        self.startDelay = startDelay
        self.volume = volume
    }
    
    init() {
        self.init(sound1: SingleSoundPreference.default1,
                  sound2: SingleSoundPreference.default2,
                  sound3: SingleSoundPreference.default3,
                  playCount: SoundPreferences.RepeatEndlessly,
                  startDelay: 3,
                  volume: 1.0)
    }

    subscript(index: SoundIndex) -> SingleSoundPreference {
        get {
            return self.sounds[ index.rawValue ]
        }
        set(newValue) {
            self.sounds[ index.rawValue ] = newValue
        }
    }
    
    func makeIterator() -> Self.Iterator {
        return self.sounds.makeIterator()
    }
    
    var underestimatedCount: Int {
        return self.sounds.underestimatedCount
    }

    func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<Self.Element>) throws -> R) rethrows -> R? {
        return try self.sounds.withContiguousStorageIfAvailable(body)
    }

    var description: String {
        return "\(type(of:self)): Play Count: \(self.playCount), startDelay: \(self.startDelay), volume: \(self.volume), Sound1: \(self[SoundIndex.sound1]), Sound2: \(self[SoundIndex.sound2]), Sound3: \(self[SoundIndex.sound3])"
    }
    
    var isEnabled: Bool {
        for sound in self.sounds {
            if sound.isEnabled {
                return true
            }
        }
        
        return false
    }
    
    static func == (lhs: SoundPreferences, rhs: SoundPreferences) -> Bool {
        return  lhs.sounds == rhs.sounds &&
                lhs.playCount == rhs.playCount &&
                lhs.startDelay == rhs.startDelay &&
                lhs.volume == rhs.volume
    }
    
    var soundSets: [SoundSet] {
        return self.sounds.map { $0.soundSet }
    }
    
    var alarmSound: AlarmSound? {
        
        let iterator = MultipleSoundSetIterator(withSoundSet: self.soundSets)
        
        if iterator.isEmpty {
            return nil
        }

        return SoundSetAlarmSound(withSoundSetIterator: iterator)
    }
    
}

extension SoundPreferences {
    
    enum CodingKeys: String, CodingKey {
        case sounds = "sounds"
        case playCount = "playCount"
        case startDelay = "startDelay"
        case volume = "volume"
    }
    
    init(withDictionary dictionary: [AnyHashable : Any]) {
    
        self.init()
        
        if let sounds = dictionary[CodingKeys.sounds.rawValue] as? [[AnyHashable: Any]] {
            for (index, soundDictionary) in sounds.enumerated() {
                
                if let sound = SingleSoundPreference(withDictionary: soundDictionary),
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

        if let volume = dictionary[CodingKeys.volume.rawValue] as? Float {
            self.volume = volume
        }

    }

    var asDictionary: [AnyHashable : Any] {
        var dictionary: [AnyHashable : Any] = [:]
        dictionary[CodingKeys.sounds.rawValue] = self.sounds.map { $0.asDictionary }
        dictionary[CodingKeys.playCount.rawValue] = self.playCount
        dictionary[CodingKeys.startDelay.rawValue] = self.startDelay
        dictionary[CodingKeys.volume.rawValue] = self.volume
        return dictionary
    }

}

