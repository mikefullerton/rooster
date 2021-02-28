//
//  SoundPreference.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation
import RoosterCore
import OSLog


public struct SoundPreferences: CustomStringConvertible, Equatable, Loggable, Codable {
    
    public static let RepeatEndlessly = SoundBehavior.RepeatEndlessly

    public private(set) var soundPreferences: [SingleSoundPreference]  {
        didSet { self.updateTimestamp() }
    }
    
    public var playCount: Int {
        didSet { self.updateTimestamp() }
    }
    
    public var startDelay: Int  {
        didSet { self.updateTimestamp() }
    }
    
    public var volume:Float {
        didSet { self.updateTimestamp() }
    }
    
    private var timestamp: Date
    
    public init() {
        self.timestamp = Date()
        self.soundPreferences = []
        self.playCount = 0
        self.startDelay = 0
        self.volume = 0
        
        self.setToDefaults()
    }
    
    public mutating func setToDefaults() {
        self.soundPreferences = [
            Self.firstDefault,
            Self.secondDefault,
            Self.thirdDefault
        ]
        
        self.playCount = Self.RepeatEndlessly
        self.startDelay = 3
        self.volume = 1.0
    }

    private mutating func updateTimestamp() {
        self.timestamp = Date()
    }
    
    public func soundPreference(forKey key: PreferenceKey) -> SingleSoundPreference {
        return self.soundPreferences[key.rawValue]
    }
    
    public mutating func setSoundPreference(_ soundPreference: SingleSoundPreference, forKey key: PreferenceKey) {
        var soundPreferences = self.soundPreferences
        soundPreferences[key.rawValue] = soundPreference
        self.soundPreferences = soundPreferences
    }
    
    public var description: String {
        return """
        \(type(of:self)): \
        timestamp: \(self.timestamp.shortDateAndLongTimeString), \
        Play Count: \(self.playCount), \
        startDelay: \(self.startDelay), \
        volume: \(self.volume), \
        Sound1: \(self.soundPreference(forKey: .first).description), \
        Sound2: \(self.soundPreference(forKey: .second).description), \
        Sound3: \(self.soundPreference(forKey: .third).description)
        """
    }
    
    public var hasEnabledSoundPreferences: Bool {
        for soundPreference in self.soundPreferences {
            if soundPreference.isEnabled {
                return true
            }
        }

        return false
    }
    
    public static func == (lhs: SoundPreferences, rhs: SoundPreferences) -> Bool {
        return  lhs.soundPreferences == rhs.soundPreferences &&
                lhs.playCount == rhs.playCount &&
                lhs.startDelay == rhs.startDelay &&
                lhs.volume == rhs.volume
    }
    
    public var soundSets: [SoundSet] {
        return self.soundPreferences.map { $0.soundSet }
    }
    
    public var enabledPlayList: PlayList {
        
        var iterators: [PlayListIteratorProtocol] = []
        
        for pref in self.soundPreferences {
            if pref.isEnabled {
                iterators.append(PlayListIterator(withSoundSet: pref.soundSet))
            }
        }
        
        let iterator = MultiPlayListIterator(withIterators: iterators)
      
        return PlayList(withPlayListIterator: iterator, displayName: "")
    }
    
    public static let `default` = SoundPreferences()

    public static let firstDefault = SingleSoundPreference(withIdentifier: "default", soundSet: SoundSet.default, enabled: true)
    public static let secondDefault = SingleSoundPreference.zero
    public static let thirdDefault = SingleSoundPreference.zero

}

extension SoundPreferences {
    public enum PreferenceKey: Int, Codable, CaseIterable, CustomStringConvertible {
        case first                = 0
        case second                = 1
        case third              = 2
        
        public var description: String {
            switch self {
            case .first:
                return "first"
                
            case .second:
                return "second"
                
            case .third:
                return "third"
            }
        }
    }
}
