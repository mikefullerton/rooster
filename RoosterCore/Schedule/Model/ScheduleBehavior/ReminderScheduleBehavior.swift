//
//  ReminderScheduleBehavior.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/10/21.
//

import Foundation

public struct ReminderScheduleBehavior: Equatable, CustomStringConvertible {
    public var priorityFilter: EventKitReminder.Priority
    public var showAllReminders: Bool
    public var defaultLengthInMinutes: Int

    @ConstrainedInt(maxValue: 7, minValue: 0) public var automaticallyIncreasePriorityDays: Int = 7

    public static let `default` = ReminderScheduleBehavior()

    public static let defaultLengthInMinutes = 15

    public init(priorityFilter: EventKitReminder.Priority,
                showAllReminders: Bool,
                defaultLengthInMinutes: Int,
                automaticallyIncreasePriorityDays: Int) {
        self.priorityFilter = priorityFilter
        self.showAllReminders = showAllReminders
        self.defaultLengthInMinutes = defaultLengthInMinutes
        self.automaticallyIncreasePriorityDays = automaticallyIncreasePriorityDays
    }

    public init() {
        self.init(priorityFilter: .none,
                  showAllReminders: true,
                  defaultLengthInMinutes: Self.defaultLengthInMinutes,
                  automaticallyIncreasePriorityDays: 0)
    }

    public var description: String {
        """
            \(type(of: self)): \
            priorityFilter: \(priorityFilter.description), \
            showAllReminders: \(showAllReminders), \
            defaultLengthInMinutes: \(defaultLengthInMinutes), \
            automaticallyIncreasePriorityDays: \(automaticallyIncreasePriorityDays)
            """
    }
}

extension ReminderScheduleBehavior: Codable {
    private enum CodingKeys: String, CodingKey {
        case priorityFilter
        case showAllReminders
        case defaultLengthInMinutes
        case automaticallyIncreasePriorityDays
    }

    public init(from decoder: Decoder) throws {
        let defaults = Self.default

        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.priorityFilter = try values.decodeIfPresent(EventKitReminder.Priority.self, forKey: .priorityFilter) ??
                                defaults.priorityFilter

        self.showAllReminders = try values.decodeIfPresent(Bool.self, forKey: .showAllReminders) ?? defaults.showAllReminders
        self.defaultLengthInMinutes = try values.decodeIfPresent(Int.self, forKey: .defaultLengthInMinutes) ?? defaults.defaultLengthInMinutes

        self.automaticallyIncreasePriorityDays = try values.decodeIfPresent(Int.self, forKey: .automaticallyIncreasePriorityDays) ??
                                defaults.automaticallyIncreasePriorityDays
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.priorityFilter, forKey: .priorityFilter)
        try container.encode(self.showAllReminders, forKey: .showAllReminders)
        try container.encode(self.defaultLengthInMinutes, forKey: .defaultLengthInMinutes)
        try container.encode(self.automaticallyIncreasePriorityDays, forKey: .automaticallyIncreasePriorityDays)
    }
}
