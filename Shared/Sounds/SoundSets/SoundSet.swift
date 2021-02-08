//
//  SoundSet.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/5/21.
//

import Foundation


struct SoundSet: CustomStringConvertible, Identifiable, Loggable, Equatable {
    
    typealias ID = String
    
    let id: String
    let url: URL?
    let displayName: String
    let soundFolder: SoundFolder
    let randomizer: SoundSetRandomizer

    init(withID id: String,
         url: URL?,
         displayName: String,
         randomizer: SoundSetRandomizer,
         soundFolder: SoundFolder) {
    
        self.randomizer = randomizer
        self.url = url
        self.displayName = displayName
        self.id = id
        self.soundFolder = soundFolder
    }

    init(withID id: String,
         url: URL?,
         displayName: String,
         randomizer: SoundSetRandomizer) {
    
        self.randomizer = randomizer
        self.url = url
        self.displayName = displayName
        self.id = id
        self.soundFolder = SoundFolder(withID: id, url: url, displayName: displayName)
    }

    static var `default`: SoundSet {
        

        var sounds: [SoundFile] = []
        
        if let roosterSounds = SoundFolder.instance.findSounds(containingNames: ["rooster crowing"]) {
            sounds.append(contentsOf: roosterSounds)
        }
        
        if let chickenSounds = SoundFolder.instance.findSounds(containingNames: [ "chicken", "rooster" ], excluding: ["rooster crowing"]) {
            sounds.append(contentsOf: chickenSounds)
        }

        let randomizer = SoundSetRandomizer(withPriority: .normal)

        let soundSet = SoundSet(withID: "Rooster_Default",
                                url: nil,
                                displayName: "Default Sound Set",
                                randomizer: randomizer)

        for (index, sound) in sounds.enumerated() {
            let newSound = SoundFile(withID: "rooster-default-\(index)",
                                     url: sound.url,
                                     displayName: sound.displayName,
                                     randomizer: randomizer)
            
            soundSet.soundFolder.addSound(newSound)
        }
        
        return soundSet
        
    }
    
    static var random: SoundSet {
        let soundSet = SoundSet(withID: "Random",
                                url: nil,
                                displayName: "Random",
                                randomizer: SoundSetRandomizer(withPriority: .normal),
                                soundFolder: SoundFolder.instance)
        return soundSet
    }
    
    static var empty: SoundSet {
        return SoundSet(withID: "Empty",
                        url: nil,
                        displayName: "Empty",
                        randomizer: SoundSetRandomizer.none)
    }
    
    var soundSetIterator: SoundSetIterator {
        return SingleSoundSetIterator(withSoundSet: self)
    }
    
    var alarmSound: AlarmSound {
        return SoundSetAlarmSound(withSoundSetIterator: self.soundSetIterator)
    }
    
    var isRandom: Bool {
        return self.randomizer.priority != .none && self.randomizer.priority != .never
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
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case displayName = "displayName"
        case randomizer = "randomizer"
        case soundFolder = "soundFolder"
        case url = "url"
    }
    
    init?(withDictionary dictionaryOrNil: [AnyHashable : Any]?) {
    
        if let dictionary = dictionaryOrNil,
           let displayName = dictionary[CodingKeys.displayName.rawValue] as? String,
           let id = dictionary[CodingKeys.id.rawValue] as? String,
           let url = dictionary[CodingKeys.url.rawValue] as? String,
           let soundFolder = SoundFolder(withDictionary: dictionary[CodingKeys.soundFolder.rawValue] as? [AnyHashable: Any]),
           let randomizer = SoundSetRandomizer(withDictionary: dictionary[CodingKeys.randomizer.rawValue] as? [AnyHashable: Any]) {
            
            self.init(withID: id,
                      url:URL(fileURLWithPath: url),
                      displayName:displayName,
                      randomizer:randomizer,
                      soundFolder: soundFolder);
            
        } else {
            return nil
        }
    }

    var asDictionary: [AnyHashable : Any] {
        var dictionary: [AnyHashable : Any] = [:]
        dictionary[CodingKeys.id.rawValue] = self.id
        dictionary[CodingKeys.displayName.rawValue] = self.displayName
        dictionary[CodingKeys.soundFolder.rawValue] = self.soundFolder.asDictionary
        dictionary[CodingKeys.randomizer.rawValue] = self.randomizer.asDictionary
        if let url = self.url {
            dictionary[CodingKeys.url.rawValue] = url.path
        }
        return dictionary
    }
}

