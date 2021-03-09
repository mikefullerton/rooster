//
//  SingleSoundPreference.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/3/21.
//

import Foundation
import RoosterCore

public struct SingleSoundPreference: CustomStringConvertible, Equatable, Identifiable {
    public typealias ID = String

    public let id: ID
    public var soundSet: SoundSet
    public var isEnabled: Bool

    public var description: String {
        """
        \(type(of: self)): \
        id: \(self.id), \
        SoundSet: \(self.soundSet.description), \
        enabled: \(self.isEnabled)
        """
    }

    public init(withIdentifier id: String,
                soundSet: SoundSet,
                enabled: Bool) {
        self.id = id
        self.soundSet = soundSet
        self.isEnabled = enabled
    }
}

extension SingleSoundPreference: Codable {
    private enum CodingKeys: String, CodingKey {
        case id
        case soundSet
        case isEnabled
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.soundSet = try values.decodeIfPresent(SoundSet.self, forKey: .soundSet) ?? SoundSet.empty
        self.isEnabled = try values.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? false
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.soundSet, forKey: .soundSet)
        try container.encode(self.isEnabled, forKey: .isEnabled)
    }
}

extension SingleSoundPreference {
    public static var random: SingleSoundPreference {
        SingleSoundPreference(withIdentifier: SoundSet.random.id, soundSet: SoundSet.random, enabled: true)
    }

    public static var empty: SingleSoundPreference {
        SingleSoundPreference(withIdentifier: SoundSet.empty.id, soundSet: SoundSet.empty, enabled: true)
    }

    public static var zero: SingleSoundPreference {
        SingleSoundPreference(withIdentifier: "zero", soundSet: SoundSet.empty, enabled: false)
    }
}
