//
//  ReminderPreferences.swift
//  RoosterCore-macOS
//
//  Created by Mike Fullerton on 3/26/21.
//

import Foundation
import RoosterCore

public struct TodayWindowPreferences: Equatable, CustomStringConvertible {
    public static let schedulePreferencesDefault = SchedulePreferences(showUnscheduledReminders: true,
                                                                       visibleDayCount: 1,
                                                                       showAllDayEvents: true,
                                                                       showDeclinedEvents: false,
                                                                       scheduleAllDayEvents: false,
                                                                       remindersDisclosed: true,
                                                                       remindersPriorityFilter: .none,
                                                                       displayOptions: .zero)

    public var schedulePreferences: SchedulePreferences

    public static let `default` = TodayWindowPreferences()

    public init() {
        self.schedulePreferences = Self.schedulePreferencesDefault
    }

    public var description: String {
        """
        \(type(of: self)): \
        schedulePreferences: \(self.schedulePreferences.description)
        """
    }

    public static var scheduleProvider: ValueProvider<SchedulePreferences> = {
        ValueProvider(getter: { AppControllers.shared.preferences.todayWindowPreferences.schedulePreferences },
                      setter: { newItem in AppControllers.shared.preferences.todayWindowPreferences.schedulePreferences = newItem })
    }()
}

extension TodayWindowPreferences: Codable {
    private enum CodingKeys: String, CodingKey {
        case schedulePreferences
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        SchedulePreferences.defaults = Self.schedulePreferencesDefault
        self.schedulePreferences = try values.decodeIfPresent(SchedulePreferences.self, forKey: .schedulePreferences) ??
            Self.schedulePreferencesDefault
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.schedulePreferences, forKey: .schedulePreferences)
    }
}
