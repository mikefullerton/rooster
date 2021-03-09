//
//  ItemPreference.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation
import RoosterCore

public struct ItemPreference: CustomStringConvertible, Equatable {
    public var soundPreference: SoundPreferences

    public static let `default` = ItemPreference()

    public init(with soundPreferences: SoundPreferences) {
        self.soundPreference = soundPreferences
    }

    public init() {
        self.init(with: SoundPreferences.default)
    }

    public var description: String {
        """
        \(type(of: self))
        """
    }
}

extension ItemPreference: Codable {
    private enum CodingKeys: String, CodingKey {
        case soundPreference
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.soundPreference = try values.decodeIfPresent(SoundPreferences.self, forKey: .soundPreference) ?? Self.default.soundPreference
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.soundPreference, forKey: .soundPreference)
    }
}
