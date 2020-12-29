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
        var name: String
        var enabled: Bool
        var random: Bool
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
    
    init(sound1: Sound,
         sound2: Sound,
         sound3: Sound,
         playCount: Int,
         startDelay: Int) {
        
        self.sounds = [
            sound1,
            sound2,
            sound3
        ]
        
        self.playCount = playCount
        self.startDelay = startDelay
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
}
