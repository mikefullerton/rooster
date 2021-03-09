//
//  SoundPlayerRandomizer.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/2/21.
//

import Foundation

public struct SoundPlayerRandomizer: Loggable, CustomStringConvertible, Equatable {
    public var frequency: Frequency
    public var behavior: Behavior

    public var description: String {
        """
        \(type(of: self)): \
        behavior: \(self.behavior), \
        frequency: \(self.frequency.description)
        """
    }

    public init() {
        self.init(withBehavior: [], frequency: .normal)
    }

    public init(withBehavior behavior: Behavior,
                frequency: Frequency) {
        self.behavior = behavior
        self.frequency = frequency
    }

    public static func == (lhs: SoundPlayerRandomizer, rhs: SoundPlayerRandomizer) -> Bool {
        lhs.behavior == rhs.behavior &&
                lhs.frequency == rhs.frequency
    }

    public static var `default` = SoundPlayerRandomizer()
}

extension SoundPlayerRandomizer: Codable {
    private enum CodingKeys: String, CodingKey {
        case frequency
        case behavior
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.frequency = try values.decodeIfPresent(Frequency.self, forKey: .frequency) ?? Self.default.frequency
        self.behavior = try values.decodeIfPresent(Behavior.self, forKey: .behavior) ?? Self.default.behavior
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.frequency, forKey: .frequency)
        try container.encode(self.behavior, forKey: .behavior)
    }
}

extension SoundPlayerRandomizer {
    public enum Frequency: Int, Codable, CustomStringConvertible, Comparable, Equatable {
        case almostNever
        case rare
        case seldom
        case low
        case normal
        case high
        case frequent

        public var description: String {
            switch self {
            case .almostNever:
                return "almostNever"

            case .rare:
                return "rare"

            case .seldom:
                return "seldom"

            case .low:
                return "low"

            case .normal:
                return "normal"

            case .high:
                return "high"

            case .frequent:
                return "frequent"
            }
        }

        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }

        public static func <= (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue <= rhs.rawValue
        }

        public static func >= (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue >= rhs.rawValue
        }

        public static func > (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue > rhs.rawValue
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue == rhs.rawValue
        }

        public static var random: Frequency {
            Frequency(rawValue: Int.random(in: 0...Frequency.frequent.rawValue))!
        }
    }

    public struct Behavior: OptionSet, CustomStringConvertible, Codable, Equatable {
        public let rawValue: Int

        public static let replaceWithRandomSoundFromSoundFolder = Behavior(rawValue: 1 << 1)
        public static let alwaysFirst                           = Behavior(rawValue: 1 << 2)

        public static let all: Behavior = [
            .replaceWithRandomSoundFromSoundFolder,
            .alwaysFirst
        ]

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static var descriptions: [(Self, String)] = [
            (.replaceWithRandomSoundFromSoundFolder, "replaceWithRandomSoundFromSoundFolder"),
            (.alwaysFirst, "alwaysFirst")
        ]

        public var description: String {
            let result: [String] = Self.descriptions.filter { contains($0.0) }.map { $0.1 }
            return "\(type(of: self)): (rawValue: \(self.rawValue)) [\(result.joined(separator: ", "))]"
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue == rhs.rawValue
        }
    }
}
