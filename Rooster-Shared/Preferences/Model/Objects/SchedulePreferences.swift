//
//  SchedulePreferences.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 4/20/21.
//

import Foundation
import RoosterCore

public struct SchedulePreferences: Equatable, CustomStringConvertible {
    public static let `default` = SchedulePreferences()

    public var showUnscheduledReminders: Bool
    public var visibleDayCount: Int
    public var showAllDayEvents: Bool
    public var showDeclinedEvents: Bool
    public var scheduleAllDayEvents: Bool
    public var remindersDisclosed: Bool
    public var remindersPriorityFilter: ReminderPriority
    public var displayOptions: DisplayOptions

    public init(showUnscheduledReminders: Bool,
                visibleDayCount: Int,
                showAllDayEvents: Bool,
                showDeclinedEvents: Bool,
                scheduleAllDayEvents: Bool,
                remindersDisclosed: Bool,
                remindersPriorityFilter: ReminderPriority,
                displayOptions: DisplayOptions) {
        self.showUnscheduledReminders = showUnscheduledReminders
        self.visibleDayCount = visibleDayCount
        self.showAllDayEvents = showAllDayEvents
        self.showDeclinedEvents = showDeclinedEvents
        self.scheduleAllDayEvents = scheduleAllDayEvents
        self.remindersDisclosed = remindersDisclosed
        self.remindersPriorityFilter = remindersPriorityFilter
        self.displayOptions = displayOptions
    }

    public init() {
        self.init(showUnscheduledReminders: true,
                  visibleDayCount: 1,
                  showAllDayEvents: true,
                  showDeclinedEvents: false,
                  scheduleAllDayEvents: false,
                  remindersDisclosed: true,
                  remindersPriorityFilter: .none,
                  displayOptions: .zero)
    }

    public var description: String {
        """
        \(type(of: self)): \
        showUnscheduledReminders: \(showUnscheduledReminders), \
        visibleDayCount: \(visibleDayCount), \
        showAllDayEvents: \(showAllDayEvents), \
        showDeclinedEvents: \(showDeclinedEvents), \
        scheduleAllDayEvents: \(scheduleAllDayEvents), \
        remindersDisclosed: \(remindersDisclosed), \
        remindersPriorityFilter: \(remindersPriorityFilter.description), \
        display options: \(displayOptions.description)
        """
    }

    static var defaults = SchedulePreferences()
}

extension SchedulePreferences {
    public struct DisplayOptions: DescribeableOptionSet {
        public let rawValue: Int

        public static var zero                 = DisplayOptions([])
        public static let showCalendarName     = DisplayOptions(rawValue: 1 << 1)

        public static let all: DisplayOptions = [ .showCalendarName ]

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static var descriptions: [(Self, String)] = [
            ( .showCalendarName, "showCalendarName")
        ]
    }
}

extension SchedulePreferences: Codable {
    private enum CodingKeys: String, CodingKey {
        case showUnscheduledReminders
        case visibleDayCount
        case showAllDayEvents
        case showDeclinedEvents
        case scheduleAllDayEvents
        case remindersDisclosed
        case remindersPriorityFilter
        case displayOptions
    }

    public static let defaultsUserInfoKey = CodingUserInfoKey(rawValue: "defaults")!

    public init(from decoder: Decoder) throws {
        let defaults = Self.defaults
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.showUnscheduledReminders = try values.decodeIfPresent(Bool.self, forKey: .showUnscheduledReminders) ?? defaults.showUnscheduledReminders
        self.showAllDayEvents = try values.decodeIfPresent(Bool.self, forKey: .showAllDayEvents) ?? defaults.showAllDayEvents
        self.showDeclinedEvents = try values.decodeIfPresent(Bool.self, forKey: .showDeclinedEvents) ?? defaults.showDeclinedEvents
        self.scheduleAllDayEvents = try values.decodeIfPresent(Bool.self, forKey: .scheduleAllDayEvents) ?? defaults.scheduleAllDayEvents
        self.visibleDayCount = try values.decodeIfPresent(Int.self, forKey: .visibleDayCount) ?? defaults.visibleDayCount
        self.remindersDisclosed = try values.decodeIfPresent(Bool.self, forKey: .remindersDisclosed) ?? defaults.remindersDisclosed
        self.remindersPriorityFilter = try values.decodeIfPresent(ReminderPriority.self, forKey: .remindersPriorityFilter) ??
            defaults.remindersPriorityFilter
        self.displayOptions = try values.decodeIfPresent(DisplayOptions.self, forKey: .displayOptions) ?? defaults.displayOptions
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.showUnscheduledReminders, forKey: .showUnscheduledReminders)
        try container.encode(self.showAllDayEvents, forKey: .showAllDayEvents)
        try container.encode(self.showDeclinedEvents, forKey: .showDeclinedEvents)
        try container.encode(self.scheduleAllDayEvents, forKey: .scheduleAllDayEvents)
        try container.encode(self.visibleDayCount, forKey: .visibleDayCount)
        try container.encode(self.remindersDisclosed, forKey: .remindersDisclosed)
        try container.encode(self.remindersPriorityFilter, forKey: .remindersPriorityFilter)
        try container.encode(self.displayOptions, forKey: .displayOptions)
    }
}
