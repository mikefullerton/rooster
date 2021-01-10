//
//  SoundPreference.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation

struct SoundPreference: Sequence, CustomStringConvertible {
    
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
}

extension SoundPreference {
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
