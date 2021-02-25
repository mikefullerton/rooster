//
//  SoundSet.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/5/21.
//

import Foundation

class SoundSet: Identifiable, Loggable, Codable, Equatable, CustomStringConvertible {
    
    typealias ID = String
    
    let id: String
    let url: URL?
    let displayName: String
    let randomizer: RandomizationDescriptor
    let soundFolder: SoundFolder
    let sounds: [String: RandomizationDescriptor]
    
    init(withID id: String,
         url: URL?,
         displayName: String,
         randomizer: RandomizationDescriptor,
         sounds: [String: RandomizationDescriptor],
         soundFolder: SoundFolder) {
    
        self.sounds = sounds
        self.randomizer = randomizer
        self.url = url
        self.displayName = displayName
        self.id = id
        self.soundFolder = soundFolder
        
    }

    static let randomSoundSetID = "b5ce82ee-30eb-4607-826f-8beb098124a0"
    static let defaultSoundSetID = "008ca3dd-f8b0-444f-a93a-5db1e9dbb353"
    static let randomSoundID = "0d67e781-826a-4c4f-807c-0dbe6514da3e"
    
    static var random: SoundSet {
        
        return SoundSet(withID: Self.randomSoundSetID,
                        url: nil,
                        displayName: "",
                        randomizer: RandomizationDescriptor(withBehavior: .always,
                                                            minSounds: 1,
                                                            maxSounds: 1),
                        sounds: [ Self.randomSoundID: RandomizationDescriptor(withBehavior: .always) ],
                        soundFolder: SoundFolder.instance)

    }
    
    static var empty: SoundSet {
        return SoundSet(withID: "Empty",
                        url: nil,
                        displayName: "Empty",
                        randomizer: RandomizationDescriptor.never,
                        sounds: [:],
                        soundFolder: SoundFolder.empty)
    }
    
    lazy var soundPlayers: [SoundFileSoundPlayer] = {
        var soundPlayers:[SoundFileSoundPlayer] = []
        for (soundID, randomizer) in self.sounds {
            
            if let soundFile = self.soundFolder.findSoundFile(forIdentifier: soundID) {
                let player = SoundFileSoundPlayer(withSoundFile: soundFile,
                                                  randomizer: randomizer)
                soundPlayers.append(player)
            } else {
                self.logger.error("Failed to load sound for SoundFile: \(soundID) in folder: \(self.soundFolder)")
            }
        }
        
        return soundPlayers
    }()
    
    
    var soundSetIterator: PlayListIteratorProtocol {
        return PlayListIterator(withSoundPlayers: self.soundPlayers,
                                randomizer: self.randomizer)
    }
    
    var playList: SoundPlayList {
        return SoundPlayList(withPlayListIterator: self.soundSetIterator, displayName: self.displayName)
    }
    
    var isRandom: Bool {
        return self.randomizer.behavior != .never
    }
    
    var isEmpty: Bool {
        return self.soundFolder.isEmpty
    }
    
    var description: String {
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

    static func == (lhs: SoundSet, rhs: SoundSet) -> Bool {
        return  lhs.id == rhs.id &&
                lhs.url == rhs.url &&
                lhs.displayName == rhs.displayName &&
                lhs.soundFolder == rhs.soundFolder &&
                lhs.sounds == rhs.sounds
    }
}

extension SoundSet {
    static var `default`: SoundSet {
        var sounds: [String: RandomizationDescriptor] = [:]
        
        if let roosterSounds = SoundFolder.instance.findSoundFiles(containing: ["rooster crowing"]) {
            let sound = roosterSounds[0]
            sounds[sound.id] = RandomizationDescriptor(withBehavior: .always, frequency: .normal, alwaysFirst: true)
        }

        if let rudeSounds = SoundFolder.instance.findSoundFiles(containing: ["excuse me"]) {
            let sound = rudeSounds[0]
            sounds[sound.id] = RandomizationDescriptor(withBehavior: .always, frequency: .almostNever, alwaysFirst: false)
        }

        if let chickenSounds = SoundFolder.instance.findSoundFiles(containing: [ "chicken", "rooster" ], excluding: ["rooster crowing"]) {
            chickenSounds.forEach {
                sounds[$0.id] = RandomizationDescriptor(withBehavior: .always, frequency: .normal, alwaysFirst: false)
            }
        }

        let soundSet = SoundSet(withID: "Rooster_Default",
                                url: URL.emptyRoosterURL,
                                displayName: "Default Sound Set",
                                randomizer: RandomizationDescriptor.always,
                                sounds: sounds,
                                soundFolder: SoundFolder.instance)
        return soundSet
        
    }
}

