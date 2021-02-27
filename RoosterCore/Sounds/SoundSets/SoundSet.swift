//
//  SoundSet.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/5/21.
//

import Foundation

public class SoundSet: Identifiable, Loggable, Codable, Equatable, CustomStringConvertible {
    
    public typealias ID = String
    
    public let id: String
    public let url: URL?
    public let displayName: String
    public let randomizer: PlayListRandomizer
    public let soundFolder: SoundFolder
    public let sounds: [String: PlayListRandomizer]
    
    public init(withID id: String,
                url: URL?,
                displayName: String,
                randomizer: PlayListRandomizer,
                sounds: [String: PlayListRandomizer],
                soundFolder: SoundFolder) {
    
        self.sounds = sounds
        self.randomizer = randomizer
        self.url = url
        self.displayName = displayName
        self.id = id
        self.soundFolder = soundFolder
        
    }

    public static let randomSoundSetID = "b5ce82ee-30eb-4607-826f-8beb098124a0"
    public static let defaultSoundSetID = "008ca3dd-f8b0-444f-a93a-5db1e9dbb353"
    public static let randomSoundID = "0d67e781-826a-4c4f-807c-0dbe6514da3e"
    
    public static var random: SoundSet {
        
        return SoundSet(withID: Self.randomSoundSetID,
                        url: nil,
                        displayName: "",
                        randomizer: PlayListRandomizer(withBehavior: .always,
                                                            minSounds: 1,
                                                            maxSounds: 1),
                        sounds: [ Self.randomSoundID: PlayListRandomizer(withBehavior: .always) ],
                        soundFolder: SoundFolder.instance)

    }
    
    public static var empty: SoundSet {
        return SoundSet(withID: "Empty",
                        url: nil,
                        displayName: "Empty",
                        randomizer: PlayListRandomizer.never,
                        sounds: [:],
                        soundFolder: SoundFolder.empty)
    }
    
    public lazy var soundPlayers: [SoundPlayer] = {
        var soundPlayers:[SoundPlayer] = []
        for (soundID, randomizer) in self.sounds {
            
            if let soundFile = self.soundFolder.findSoundFile(forIdentifier: soundID) {
                let player = SoundPlayer(withSoundFile: soundFile,
                                                  randomizer: randomizer)
                soundPlayers.append(player)
            } else {
                self.logger.error("Failed to load sound for SoundFile: \(soundID) in folder: \(self.soundFolder)")
            }
        }
        
        return soundPlayers
    }()
    
    public var soundSetIterator: PlayListIteratorProtocol {
        return PlayListIterator(withSoundPlayers: self.soundPlayers,
                                randomizer: self.randomizer)
    }
    
    public var playList: PlayList {
        return PlayList(withPlayListIterator: self.soundSetIterator, displayName: self.displayName)
    }
    
    public var isRandom: Bool {
        return self.randomizer.behavior != .never
    }
    
    public var isEmpty: Bool {
        return self.soundFolder.isEmpty
    }
    
    public var description: String {
        let sounds = self.soundPlayers.map { $0.soundFile.description }.joined(separator: ",")
        return """
        \(type(of:self)): \
        id: \(self.id), \
        displayName: \
        \(self.displayName), \
        url: \(String(describing:self.url)), \
        randomizer: \(self.randomizer), \
        sounds: \(sounds), \
        soundFolder: \(self.soundFolder.description)"
        """
    }

    public static func == (lhs: SoundSet, rhs: SoundSet) -> Bool {
        return  lhs.id == rhs.id &&
                lhs.url == rhs.url &&
                lhs.displayName == rhs.displayName &&
                lhs.soundFolder == rhs.soundFolder &&
                lhs.sounds == rhs.sounds
    }
}

extension SoundSet {
    public static var `default`: SoundSet {
        var sounds: [String: PlayListRandomizer] = [:]
        
        if let roosterSounds = SoundFolder.instance.findSoundFiles(containing: ["rooster crowing"]) {
            let sound = roosterSounds[0]
            sounds[sound.id] = PlayListRandomizer(withBehavior: .always, frequency: .normal, alwaysFirst: true)
        }

        if let rudeSounds = SoundFolder.instance.findSoundFiles(containing: ["excuse me"]) {
            let sound = rudeSounds[0]
            sounds[sound.id] = PlayListRandomizer(withBehavior: .always, frequency: .almostNever, alwaysFirst: false)
        }

        if let chickenSounds = SoundFolder.instance.findSoundFiles(containing: [ "chicken", "rooster" ], excluding: ["rooster crowing"]) {
            chickenSounds.forEach {
                sounds[$0.id] = PlayListRandomizer(withBehavior: .always, frequency: .normal, alwaysFirst: false)
            }
        }

        let soundSet = SoundSet(withID: "Rooster_Default",
                                url: URL.emptyRoosterURL,
                                displayName: "Default Sound Set",
                                randomizer: PlayListRandomizer.always,
                                sounds: sounds,
                                soundFolder: SoundFolder.instance)
        return soundSet
        
    }
}

