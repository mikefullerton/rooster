//
//  SoundSet.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/5/21.
//

import Foundation

public class SoundSet: Identifiable, Loggable, Codable, Equatable, CustomStringConvertible {
    public typealias ID = String

    public var id: String
    public var url: URL?
    public var displayName: String
    public var randomizer: PlayListRandomizer
    public var soundFolder: SoundFolder
    public var soundFileCollection: SoundFileCollection

    public init(withID id: String,
                url: URL?,
                displayName: String,
                randomizer: PlayListRandomizer,
                soundFileCollection: SoundFileCollection,
                soundFolder: SoundFolder) {
        self.soundFileCollection = soundFileCollection
        self.randomizer = randomizer
        self.url = url
        self.displayName = displayName
        self.id = id
        self.soundFolder = soundFolder
    }

    public lazy var soundPlayers: [SoundPlayer] = {
        var soundPlayers: [SoundPlayer] = []
        for (soundID, randomizer) in self.soundFileCollection.randomizerMap {
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

    public lazy var soundFiles: [SoundFile] = {
        self.soundPlayers.map { $0.soundFile }
    }()

    public var isEmpty: Bool {
        self.soundFolder.isEmpty
    }

    public var description: String {
        """
        \(type(of: self)): \
        id: \(self.id), \
        displayName: \(self.displayName), \
        url: \(String(describing: self.url)), \
        randomizer: \(self.randomizer), \
        soundFileCollection: \(self.soundFileCollection.description), \
        soundFolder: \(self.soundFolder.description)"
        """
    }

    public static func == (lhs: SoundSet, rhs: SoundSet) -> Bool {
        lhs.id == rhs.id &&
        lhs.url == rhs.url &&
        lhs.displayName == rhs.displayName &&
        lhs.randomizer == rhs.randomizer &&
        lhs.soundFolder == rhs.soundFolder &&
        lhs.soundFileCollection == rhs.soundFileCollection
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case url
        case displayName
        case randomizer
        case soundFolder
        case soundFileCollection
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.url = try values.decodeIfPresent(URL.self, forKey: .url) ?? URL.empty
        self.randomizer = try values.decodeIfPresent(PlayListRandomizer.self, forKey: .randomizer) ?? PlayListRandomizer()
        self.soundFolder = try values.decodeIfPresent(SoundFolder.self, forKey: .soundFolder) ?? SoundFolder()
        self.soundFileCollection = try values.decodeIfPresent(SoundFileCollection.self, forKey: .soundFileCollection) ?? SoundFileCollection()
        self.displayName = try values.decodeIfPresent(String.self, forKey: .displayName) ?? ""
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.url, forKey: .url)
        try container.encode(self.randomizer, forKey: .randomizer)
        try container.encode(self.soundFolder, forKey: .soundFolder)
        try container.encode(self.soundFileCollection, forKey: .soundFileCollection)
        try container.encode(self.displayName, forKey: .displayName)
    }
}

extension SoundSet {
    public static let randomSoundSetID = "b5ce82ee-30eb-4607-826f-8beb098124a0"

    public static var random: SoundSet {
        var soundFileCollection = SoundFileCollection()
        soundFileCollection.addSound(SoundFolder.instance.randomSoundFile,
                                     randomizer: SoundPlayerRandomizer(withBehavior: .replaceWithRandomSoundFromSoundFolder,
                                                                       frequency: .normal))

        return SoundSet(withID: Self.randomSoundSetID,
                        url: nil,
                        displayName: "",
                        randomizer: PlayListRandomizer(withBehavior: .randomizeOrder),
                        soundFileCollection: soundFileCollection,
                        soundFolder: SoundFolder.instance)
    }

    public static let emptySoundSetID = "fbdea4b7-e0cb-43c9-bf52-fdd74ffd28f8"

    public static var empty: SoundSet {
        SoundSet(withID: Self.emptySoundSetID,
                 url: nil,
                 displayName: "",
                 randomizer: PlayListRandomizer.default,
                 soundFileCollection: SoundFileCollection(),
                 soundFolder: SoundFolder.empty)
    }

    public static let defaultSoundSetID = "008ca3dd-f8b0-444f-a93a-5db1e9dbb353"

    public static var `default`: SoundSet {
        var soundFileCollection = SoundFileCollection()

        if let roosterSounds = SoundFolder.instance.findSoundFiles(containing: ["rooster crowing"]) {
            soundFileCollection.addSound(roosterSounds[0], randomizer: SoundPlayerRandomizer(withBehavior: .alwaysFirst,
                                                                                             frequency: .normal))
        }

        if let rudeSounds = SoundFolder.instance.findSoundFiles(containing: ["excuse me"]) {
            soundFileCollection.addSound(rudeSounds[0], randomizer: SoundPlayerRandomizer(withBehavior: [],
                                                                                          frequency: .almostNever))
        }

        if let chickenSounds = SoundFolder.instance.findSoundFiles(containing: [ "chicken", "rooster" ],
                                                                   excluding: ["rooster crowing"]) {
            chickenSounds.forEach {
                soundFileCollection.addSound($0, randomizer: SoundPlayerRandomizer(withBehavior: [],
                                                                                   frequency: .normal))
            }
        }

        let soundSet = SoundSet(withID: "Rooster_Default",
                                url: URL.empty,
                                displayName: "Default Sound Set",
                                randomizer: PlayListRandomizer(withBehavior: .randomizeOrder),
                                soundFileCollection: soundFileCollection,
                                soundFolder: SoundFolder.instance)
        return soundSet
    }
}
