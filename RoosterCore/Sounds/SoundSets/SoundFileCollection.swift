//
//  SoundFileCollection.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/2/21.
//

import Foundation

public struct SoundFileCollection: CustomStringConvertible, Equatable {
    public private(set) var randomizerMap: [String: SoundPlayerRandomizer]
    public private(set) var relativePathMap: [String: URL]

    public static let `default` = SoundFileCollection()

    public var description: String {
        """
        \(type(of: self)): \
        relativePaths: \(self.relativePathMap)
        """
    }

    public var count: Int {
        self.relativePathMap.count
    }

    public init() {
        self.randomizerMap = [:]
        self.relativePathMap = [:]
    }

    public var allSoundIDs: [String] {
        self.relativePathMap.keys.map { $0 as String }
    }

    public func randomizer(forID id: String) -> SoundPlayerRandomizer? {
        self.randomizerMap[id]
    }

    public func relativePath(forID id: String) -> URL? {
        self.relativePathMap[id]
    }

    public mutating func addSound(_ soundFile: SoundFile, randomizer: SoundPlayerRandomizer) {
        self.randomizerMap[soundFile.id] = randomizer
        self.relativePathMap[soundFile.id] = soundFile.relativePath
    }

    public static func == (lhs: SoundFileCollection, rhs: SoundFileCollection) -> Bool {
        lhs.randomizerMap == rhs.randomizerMap &&
                lhs.relativePathMap == rhs.relativePathMap
    }

    var randomSoundID: String? {
        self.relativePathMap.keys.randomElement()
    }
}

extension SoundFileCollection: Codable {
    private enum CodingKeys: String, CodingKey {
        case randomizerMap
        case relativePathMap
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.randomizerMap = try values.decodeIfPresent([String: SoundPlayerRandomizer].self, forKey: .randomizerMap) ?? Self.default.randomizerMap
        self.relativePathMap = try values.decodeIfPresent([String: URL].self, forKey: .relativePathMap) ?? Self.default.relativePathMap
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.randomizerMap, forKey: .randomizerMap)
        try container.encode(self.relativePathMap, forKey: .relativePathMap)
    }
}
