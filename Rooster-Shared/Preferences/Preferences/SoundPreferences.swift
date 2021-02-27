//
//  SoundPreference.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation
import RoosterCore
import OSLog


struct SoundPreferences: CustomStringConvertible, Equatable, Loggable, Codable {
    
    static let RepeatEndlessly = SoundBehavior.RepeatEndlessly

    enum SoundPreferenceKey : String, Codable {
        case sound1
        case sound2
        case sound3
    }
    
    private(set) var soundPreferences: [SoundPreferenceKey: SingleSoundPreference]
    
    var playCount: Int
    var startDelay: Int
    var volume:Float
    
    init(withSoundPreferences soundPreferences: [SoundPreferenceKey: SingleSoundPreference],
         playCount: Int,
         startDelay: Int,
         volume: Float) {
        
        self.soundPreferences = soundPreferences
        self.playCount = playCount
        self.startDelay = startDelay
        self.volume = volume
    }
    
    init() {
        let defaults = [
            SoundPreferenceKey.sound1 : SingleSoundPreference.default1,
            SoundPreferenceKey.sound2 : SingleSoundPreference.default2,
            SoundPreferenceKey.sound3 : SingleSoundPreference.default3
        ]
        
        self.init(withSoundPreferences:defaults,
                  playCount: SoundPreferences.RepeatEndlessly,
                  startDelay: 3,
                  volume: 1.0)
    }

    func soundPreference(forKey key: SoundPreferenceKey) -> SingleSoundPreference {
        return self.soundPreferences[key]!
    }
    
    mutating func setSoundPreference(_ soundPreference: SingleSoundPreference, forKey key: SoundPreferenceKey) {
        self.soundPreferences[key] = soundPreference;
    }
    
    var description: String {
        return """
        \(type(of:self)): \
        Play Count: \(self.playCount), \
        startDelay: \(self.startDelay), \
        volume: \(self.volume), \
        Sound1: \(self.soundPreference(forKey: .sound1).description), \
        Sound2: \(self.soundPreference(forKey: .sound2).description), \
        Sound3: \(self.soundPreference(forKey: .sound3).description)
        """
    }
    
    var hasEnabledSoundPreferences: Bool {
        for soundPreference in self.soundPreferences.values {
            if soundPreference.isEnabled {
                return true
            }
        }

        return false
    }
    
    static func == (lhs: SoundPreferences, rhs: SoundPreferences) -> Bool {
        return  lhs.soundPreferences == rhs.soundPreferences &&
                lhs.playCount == rhs.playCount &&
                lhs.startDelay == rhs.startDelay &&
                lhs.volume == rhs.volume
    }
    
    var soundSets: [SoundSet] {
        return self.soundPreferences.values.map { $0.soundSet }
    }
    
    var allSoundsIterator: MultiPlayListIterator {
        let iteratorList = self.soundSets.map { return $0.soundSetIterator }
        let iterator = MultiPlayListIterator(withIterators: iteratorList)
      
        return iterator
    }
}

