//
//  SoundSet.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/5/21.
//

import Foundation

struct SoundSet: Identifiable, Loggable, Codable, Equatable, CustomStringConvertible {
    
    typealias ID = String
    
    let id: String
    let url: URL
    let displayName: String
    let randomizer: RandomizationDescriptor
    let soundFolder: SoundFolder
    
    init(withID id: String,
         url: URL,
         displayName: String,
         randomizer: RandomizationDescriptor,
         soundFolder: SoundFolder) {
    
        self.randomizer = randomizer
        self.url = url
        self.displayName = displayName
        self.id = id
        self.soundFolder = soundFolder
    }

    static var random: SoundSet {
        return SoundSet(withID: "All Sounds",
                        url: URL.roosterURL("All Sounds Sound Set"),
                        displayName: "All Sounds",
                        randomizer: RandomizationDescriptor(withBehavior: .always,
                                                       minSounds: 1,
                                                       maxSounds: 1),
                        soundFolder: SoundFolder.instance)

    }
    
    static var empty: SoundSet {
        return SoundSet(withID: "Empty",
                        url: URL.roosterURL("Empty Sound Set"),
                        displayName: "Empty",
                        randomizer: RandomizationDescriptor.none,
                        soundFolder: SoundFolder.empty)
    }
    
    var soundSetIterator: PlayListIteratorProtocol {
        return PlayListIterator(withSounds: self.soundFolder.allSounds, randomizer: self.randomizer)
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
        return "\(type(of:self)): id: \(self.id), displayName: \(self.displayName), randomizer: \(self.randomizer), soundFolder: \(self.soundFolder.description)"
    }

    static func == (lhs: SoundSet, rhs: SoundSet) -> Bool {
        return lhs.id == rhs.id &&
        lhs.url == rhs.url &&
        lhs.displayName == rhs.displayName &&
        lhs.soundFolder == rhs.soundFolder
        
    }
}

extension SoundSet {
    static var `default`: SoundSet {
        let folder = SoundFolder.defaultSoundSetFolder
        
        let soundSet = SoundSet(withID: "Rooster_Default",
                                url: folder.url,
                                displayName: "Default Sound Set",
                                randomizer: RandomizationDescriptor.always,
                                soundFolder: SoundFolder.defaultSoundSetFolder)
        return soundSet
        
    }
}

extension SoundFolder {
    static var defaultSoundSetFolder: SoundFolder {
        
        var sounds: [SoundFile] = []
        
        if let roosterSounds = SoundFolder.instance.findSounds(containing: ["rooster crowing"]) {
            let sound = roosterSounds[0]
            sound.randomizer = RandomizationDescriptor(withBehavior: .always, frequency: .normal, alwaysFirst: true)
            sounds.append(contentsOf: [sound])
        }

        if let rudeSounds = SoundFolder.instance.findSounds(containing: ["excuse me"]) {
            let sound = rudeSounds[0]
            sound.randomizer = RandomizationDescriptor(withBehavior: .always, frequency: .almostNever, alwaysFirst: false)
            sounds.append(contentsOf: [sound])
        }

        if let chickenSounds = SoundFolder.instance.findSounds(containing: [ "chicken", "rooster" ], excluding: ["rooster crowing"]) {
            sounds.append(contentsOf: chickenSounds)
        }

        var newSounds:[SoundFile] = []
        for (index, sound) in sounds.enumerated() {
            let newSound = SoundFile(withID: "rooster-default-\(index)",
                                     url: sound.url,
                                     displayName: sound.displayName,
                                     randomizer: sound.randomizer)
            
            newSounds.append(newSound)
        }
        
        return SoundFolder(withID: "rooster_default_sound_set",
                           url: URL.roosterURL("default-sound-set"),
                           displayName: "rooster_default_sound_set",
                           sounds: newSounds,
                           subFolders: [])
    }
}
