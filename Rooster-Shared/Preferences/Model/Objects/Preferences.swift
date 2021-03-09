//
//  Preferences.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation
import RoosterCore

public struct Preferences: CustomStringConvertible, Loggable, Equatable {
    public var soundPreferences: SoundPreferences
    public var notifications: NotificationPreferences
    public var menuBar: MenuBarPreferences
    public var general: GeneralPreferences
    public var calendar: CalendarPreferences
    public var reminders: ReminderPreferences
    public var events: EventPreferences

    public static let `default` = Preferences()

    public init(withSoundPreferences soundPreferences: SoundPreferences,
                notifications: NotificationPreferences,
                menuBarPreferences: MenuBarPreferences,
                general: GeneralPreferences,
                calendar: CalendarPreferences,
                events: EventPreferences,
                reminders: ReminderPreferences) {
        self.soundPreferences = soundPreferences
        self.notifications = notifications
        self.menuBar = menuBarPreferences
        self.general = general
        self.calendar = calendar
        self.events = events
        self.reminders = reminders
    }

    private init() {
        self.init(withSoundPreferences: SoundPreferences.default,
                  notifications: NotificationPreferences.default,
                  menuBarPreferences: MenuBarPreferences.default,
                  general: GeneralPreferences.default,
                  calendar: CalendarPreferences(),
                  events: EventPreferences(),
                  reminders: ReminderPreferences())
    }

    public var description: String {
        """
        \(type(of: self)): \
        general: \(self.general.description), \
        notifications: \(self.notifications.description), \
        sounds: \(self.soundPreferences.description), \
        menuBar: \(self.menuBar.description), \
        calendar: \(self.calendar.description) \
        events: \(self.events.description) \
        reminders: \(self.reminders.description)
        """
    }
}

extension Preferences: Codable {
    private enum CodingKeys: String, CodingKey {
        case sounds
        case notifications
        case menuBar
        case general
        case calendar
        case reminders
        case events
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.soundPreferences = try values.decodeIfPresent(SoundPreferences.self, forKey: .sounds) ?? Self.default.soundPreferences
        self.notifications = try values.decodeIfPresent(NotificationPreferences.self, forKey: .notifications) ?? Self.default.notifications
        self.menuBar = try values.decodeIfPresent(MenuBarPreferences.self, forKey: .menuBar) ?? Self.default.menuBar
        self.general = try values.decodeIfPresent(GeneralPreferences.self, forKey: .general) ?? Self.default.general
        self.calendar = try values.decodeIfPresent(CalendarPreferences.self, forKey: .calendar) ?? Self.default.calendar
        self.reminders = try values.decodeIfPresent(ReminderPreferences.self, forKey: .reminders) ?? Self.default.reminders
        self.events = try values.decodeIfPresent(EventPreferences.self, forKey: .events) ?? Self.default.events
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.soundPreferences, forKey: .sounds)
        try container.encode(self.notifications, forKey: .notifications)
        try container.encode(self.menuBar, forKey: .menuBar)
        try container.encode(self.general, forKey: .general)
        try container.encode(self.calendar, forKey: .calendar)
        try container.encode(self.reminders, forKey: .reminders)
        try container.encode(self.events, forKey: .events)
    }
}

extension Preferences {
    var scheduleBehavior: ScheduleBehavior {
        let scheduleBehavior = ScheduleBehavior(calendarScheduleBehavior: self.calendar.scheduleBehavior,
                                                eventScheduleBehavior: self.events.scheduleBehavior,
                                                reminderScheduleBehavior: self.reminders.scheduleBehavior)
        return scheduleBehavior
    }
}
