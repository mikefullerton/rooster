//
//  SoundPreference.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation

struct SoundPreference: Sequence {
    
    typealias Element = Sound
    typealias Iterator = Array<Sound>.Iterator
    
    struct Sound {
        
        var url: URL?
        var enabled: Bool
        var random: Bool
        
        init(url: URL?,
             enabled: Bool,
             random: Bool) {
            
            self.url = url
            self.random = random
            self.enabled = enabled && url != nil
        }
        
        var name: String {
            return self.url?.fileName ?? ""
        }
        
        static var zero: Sound {
            return Sound(url:nil, enabled: false, random: false)
        }
    }
    
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

}

extension SoundPreference {
    
    var soundURLs: [URL] {
        
        var outURLs:[URL] = []
        
        let availableURLs = Bundle.availableSoundResources
        
        for sound in self {
            for url in availableURLs {
                let fileName = url.fileName
                if fileName == sound.name {
                    outURLs.append(url)
                }
            }
        }
        
        return outURLs
    }
    
    static var availableSounds: [String] {
        let availableURLs = Bundle.availableSoundResources
        return availableURLs.map { $0.fileName }
    }
    
    static var availableSoundURLs: [URL] {
        return Bundle.availableSoundResources
    }
    
    static func urlForName(_ name: String) -> URL? {
        for url in self.availableSoundURLs {
            if url.fileName == name {
                return url
            }
        }
        
        return nil
    }
}
