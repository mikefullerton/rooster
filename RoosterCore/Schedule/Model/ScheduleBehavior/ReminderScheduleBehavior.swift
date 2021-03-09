//  ReminderScheduleBehavior.swift
//
//  Created by Mike Fullerton on 4/10/21.
//

import Foundation

public struct ReminderScheduleBehavior: Equatable, CustomStringConvertible {
    public var defaultLengthInMinutes: Int

    @ConstrainedInt(maxValue: 7, minValue: 0) public var automaticallyIncreasePriorityDays: Int = 7

    public static let `default` = ReminderScheduleBehavior()

    public static let defaultLengthInMinutes = 15

    public init(defaultLengthInMinutes: Int,
                automaticallyIncreasePriorityDays: Int) {
        self.defaultLengthInMinutes = defaultLengthInMinutes
        self.automaticallyIncreasePriorityDays = automaticallyIncreasePriorityDays
    }

    public init() {
        self.init(defaultLengthInMinutes: Self.defaultLengthInMinutes,
                  automaticallyIncreasePriorityDays: 0)
    }

    public var description: String {
        """
            \(type(of: self)): \
            defaultLengthInMinutes: \(defaultLengthInMinutes), \
            automaticallyIncreasePriorityDays: \(automaticallyIncreasePriorityDays)
            """
    }
}

extension ReminderScheduleBehavior: Codable {
    private enum CodingKeys: String, CodingKey {
        case showAllReminders
        case defaultLengthInMinutes
        case automaticallyIncreasePriorityDays
    }

    public init(from decoder: Decoder) throws {
        let defaults = Self.default

        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.defaultLengthInMinutes = try values.decodeIfPresent(Int.self, forKey: .defaultLengthInMinutes) ?? defaults.defaultLengthInMinutes

        self.automaticallyIncreasePriorityDays = try values.decodeIfPresent(Int.self, forKey: .automaticallyIncreasePriorityDays) ??
                                defaults.automaticallyIncreasePriorityDays
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.defaultLengthInMinutes, forKey: .defaultLengthInMinutes)
        try container.encode(self.automaticallyIncreasePriorityDays, forKey: .automaticallyIncreasePriorityDays)
    }
}
