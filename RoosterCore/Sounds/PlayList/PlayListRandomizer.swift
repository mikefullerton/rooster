//
//  SoundSetRandomizer.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/8/21.
//

import Foundation

public struct PlayListRandomizer: Loggable, CustomStringConvertible, Equatable {
    public var behavior: Behavior

    public init() {
        self.behavior = []
    }

    public init(withBehavior behavior: Behavior) {
        self.behavior = behavior
    }

    public static var `default` = PlayListRandomizer()

    public var description: String {
        """
        \(type(of: self)): \
        behavior: \(self.behavior.description)
        """
    }
}

extension PlayListRandomizer: Codable {
    private enum CodingKeys: String, CodingKey {
        case behavior
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.behavior = try values.decodeIfPresent(Behavior.self, forKey: .behavior) ?? .zero
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.behavior, forKey: .behavior)
    }
}

extension PlayListRandomizer {
    public struct Behavior: DescribeableOptionSet {
        public let rawValue: Int

        public static var zero                  = Behavior([])
        public static let randomizeOrder        = Behavior(rawValue: 1 << 1)
        public static let regenerateEachPlay    = Behavior(rawValue: 1 << 2)

        public static let all: Behavior = [
            .randomizeOrder, .regenerateEachPlay
        ]

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static var descriptions: [(Self, String)] = [
            (.randomizeOrder, "randomizeOrder"),
            (.regenerateEachPlay, "regenerateEachPaly")
        ]
    }
}
