//
//  SoundSet.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/5/21.
//

import Foundation

class SoundSet: CustomStringConvertible, Equatable, Identifiable {

    typealias ID = String
    
    let soundDescriptors: [SoundFileDescriptor]
    let name: String
    let id: String
 
    init(withIdentifier id: String,
         name:String,
         soundIdentifiers: [SoundFileDescriptor]) {
        self.id = id
        self.name = name
        self.soundDescriptors = soundIdentifiers
    }
    
    var isEmpty: Bool {
        return self.soundDescriptors.count == 0
    }
    
    func contains(_ identifier: String) -> Bool {
        return self.soundDescriptors.contains { identifier == $0.id }
    }
    
    var soundFileDescriptors: [SoundFileDescriptor] {
        return self.soundDescriptors
    }

    lazy var soundIdentifiers: [String] = {
        return self.soundDescriptors.map { return $0.id }
    }()

    func soundFileDescriptor(forSoundIdentifier id: String) -> SoundFileDescriptor? {
        if let index = self.soundDescriptors.firstIndex(where: {
            $0.id == id
        }) {
            return self.soundDescriptors[index]
        }
        
        return nil
    }
 
    static func == (lhs: SoundSet, rhs: SoundSet) -> Bool {
        return  lhs.soundDescriptors == rhs.soundDescriptors &&
                lhs.name == rhs.name &&
                lhs.id == rhs.id
    }
    
    var description: String {
        return "\(type(of:self)): id: \(self.id), name: \(self.name), soundDescriptors: [\(self.soundDescriptors.map { $0.description }.joined(separator: ", "))]"
    }
        
    static var `default`: SoundSet {
        
        var defaultIdentifiers: [SoundFileDescriptor] = []
        
        if let identifiers = SoundFolder.instance.findSoundIdentifers(containingNames: ["rooster crowing"]) {
            defaultIdentifiers.append(SoundFileDescriptor(with: identifiers[0], randomizerPriority:.never))
        }
        
        if let randomIdentifiers = SoundFolder.instance.findSoundIdentifers(containingNames: [ "chicken", "rooster" ], excluding: ["rooster crowing"]) {
            defaultIdentifiers.append(contentsOf: randomIdentifiers.map { SoundFileDescriptor(with: $0, randomizerPriority: .normal) })
        }

        return SoundSet(withIdentifier: "Rooster_Default",
                        name: "Default Sound Set",
                        soundIdentifiers: defaultIdentifiers)
    }
    
    static var random: SoundSet {
        return SoundSet(withIdentifier: "Random", name: "Random", soundIdentifiers: [ SoundFileDescriptor.random ])
    }
    
    static var empty: SoundSet {
        return SoundSet(withIdentifier: "Empty", name: "Empty", soundIdentifiers: [ SoundFileDescriptor.random ])
    }
    
    var soundCount: Int {
        return self.soundDescriptors.count
    }
    
    var isRandom: Bool {
        return self.soundDescriptors.count == 1 && self.soundDescriptors[0].isAnyRandomSound
    }
    
    func soundFile(forIdentifier id: String) -> SoundFile? {
        if let index = self.sounds.firstIndex(where: { $0.id == id } ) {
            return self.sounds[index];
        }
        return nil
    }
    
    lazy var sounds: [SoundFile] = {
        return SoundFolder.instance.findSounds(forIdentifiers: self.soundIdentifiers)
    }()
    
    var soundSetIterator: SoundSetIterator {
        return SingleSoundSetIterator(withSoundSet: self)
    }
    
    var alarmSound: AlarmSound {
        return SoundSetAlarmSound(withSoundSetIterator: self.soundSetIterator)
    }
    
    var displayName: String {
        if self.isRandom {
            return "Random"
        } else {
//            self.checkbox.title = "\(soundFile.displayName) (Randomly Chosen)"
            return "SoundSet"
        }
    }
}

extension SoundSet {
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case soundIdentifiers = "soundIdentifiers"
    }
    
    convenience init?(withDictionary dictionary: [AnyHashable : Any]) {
        if let soundIdentifiersList = dictionary[CodingKeys.soundIdentifiers.rawValue] as? [[AnyHashable: Any]],
           let name = dictionary[CodingKeys.name.rawValue] as? String,
           let id = dictionary[CodingKeys.id.rawValue] as? String {
            
            let soundIdentifiers: [SoundFileDescriptor] = soundIdentifiersList.map { SoundFileDescriptor(withDictionary: $0) ?? SoundFileDescriptor() }
            
            self.init(withIdentifier: id, name: name, soundIdentifiers: soundIdentifiers)
        } else {
            return nil
        }
    }

    var asDictionary: [AnyHashable : Any] {
        var dictionary: [AnyHashable : Any] = [:]
        dictionary[CodingKeys.id.rawValue] = self.id
        dictionary[CodingKeys.name.rawValue] = self.name
        dictionary[CodingKeys.soundIdentifiers.rawValue] = self.soundDescriptors.map { $0.asDictionary }
        return dictionary
    }
}

