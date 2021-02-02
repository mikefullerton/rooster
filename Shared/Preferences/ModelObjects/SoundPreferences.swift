//
//  SoundPreference.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation

struct SoundPreferences: Sequence, CustomStringConvertible {
    
    typealias Element = Sound
    typealias Iterator = Array<Sound>.Iterator
    
    static let RepeatEndlessly = AlarmSoundBehavior.RepeatEndlessly

    enum SoundIndex : Int {
        case sound1
        case sound2
        case sound3
    }

    private(set) var sounds: [Sound]
    
    var playCount: Int
    var startDelay: Int
    var volume:Float
    
    init(sound1: Sound,
         sound2: Sound,
         sound3: Sound,
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
        if let defaultURL = SoundPreferences.urlForName("Rooster Crowing") {
            self.init(sound1: Sound(url: defaultURL, enabled: true, random: false),
                      sound2: Sound.zero,
                      sound3: Sound.zero,
                      playCount: SoundPreferences.RepeatEndlessly,
                      startDelay: 3,
                      volume: 1.0)
            return
        }
        
        self.init(sound1: Sound.zero,
                  sound2: Sound.zero,
                  sound3: Sound.zero,
                  playCount: SoundPreferences.RepeatEndlessly,
                  startDelay: 3,
                  volume: 1.0)
    }

    subscript(index: SoundIndex) -> Sound {
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
        return "Sound preference: Play Count: \(self.playCount), startDelay: \(self.startDelay), volume: \(self.volume), Sound1: \(self[SoundIndex.sound1]), Sound2: \(self[SoundIndex.sound2]), Sound3: \(self[SoundIndex.sound3])"
    }
    
    var isEnabled: Bool {
        for sound in self.sounds {
            if sound.enabled {
                return true
            }
        }
        
        return false
    }
}

extension SoundPreferences {
    struct Sound : CustomStringConvertible {
        
        private var _url: URL?
        var enabled: Bool
        var random: Bool
        
        init(url: URL?,
             enabled: Bool,
             random: Bool) {
            
            self._url = url
            self.random = random
            self.enabled = enabled && url != nil
        }
        
        var soundName: String {
            if self.random {
                return "Randomized"
            }
            return self.url?.soundName ?? ""
        }
        
        var url: URL? {
            get {
                if self.random {
                    return URL.randomizedSound
                }
                
                return self._url
            }
            set(url) {
                self._url = url
            }
        }
        
        static var zero: Sound {
            return Sound(url:nil, enabled: false, random: false)
        }
        
        var description: String {
            return "Sound: \(self.url?.description ?? "nil" ), enabled: \(self.enabled), random: \(self.random)"
        }
    }
    
    
}

extension URL {
    
    static var randomizedSound: URL {
        return URL(string: "rooster://randomized")!
    }
    
    var isRandomizedSound: Bool {
        return self == URL.randomizedSound
    }
}

extension SoundPreferences.Sound {
    enum CodingKeys: String, CodingKey {
        case url = "name"
        case enabled = "enabled"
        case random = "random"
    }
    
    init?(withDictionary dictionary: [AnyHashable : Any]) {
    
        self.enabled = false
        self.random = false
        self.url = URL(string:"")
        
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

extension SoundPreferences {
    
    enum CodingKeys: String, CodingKey {
        case sounds = "sounds"
        case playCount = "playCount"
        case startDelay = "startDelay"
    }
    
    init(withDictionary dictionary: [AnyHashable : Any]) {
    
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
