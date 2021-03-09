//
//  MenuBarPreferences.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/2/21.
//

import Foundation
import RoosterCore

public struct MenuBarPreferences: CustomStringConvertible, Equatable {
    public static let schedulePreferencesDefault = SchedulePreferences(showUnscheduledReminders: false,
                                                                       visibleDayCount: 1,
                                                                       showAllDayEvents: false,
                                                                       showDeclinedEvents: false,
                                                                       scheduleAllDayEvents: false,
                                                                       remindersDisclosed: true,
                                                                       remindersPriorityFilter: .none,
                                                                       displayOptions: .zero)

    public enum CountDownFormat: Int, Codable, CustomStringConvertible {
        case short
        case long
        case digitalClock

        public var description: String {
            switch self {
            case .short:
                return "short"

            case .long:
                return "long"

            case .digitalClock:
                return "digitalClock"
            }
        }
    }

    public var showInMenuBar: Bool
    public var showCountDown: Bool
    public var blink: Bool
    public var countDownFormat: CountDownFormat
    public var schedulePreferences: SchedulePreferences

    public static let `default` = MenuBarPreferences()

    public init(showInMenuBar: Bool,
                showCountDown: Bool,
                blink: Bool,
                countDownFormat: CountDownFormat,
                schedulePreferences: SchedulePreferences) {
        self.showInMenuBar = showInMenuBar
        self.showCountDown = showCountDown
        self.blink = blink
        self.countDownFormat = countDownFormat
        self.schedulePreferences = schedulePreferences
    }

    public init() {
        self.init(showInMenuBar: true,
                  showCountDown: true,
                  blink: true,
                  countDownFormat: .digitalClock,
                  schedulePreferences: Self.schedulePreferencesDefault)
    }

    public var description: String {
        """
        \(type(of: self)): \
        showInMenuBar: \(showInMenuBar), \
        showCountDown: \(showCountDown), \
        blink: \(blink), \
        countDownFormat: \(countDownFormat.description), \
        schedulePreferences: \(schedulePreferences.description)
        """
    }

    public static var scheduleProvider: ValueProvider<SchedulePreferences> {
        ValueProvider(getter: { AppControllers.shared.preferences.menuBar.schedulePreferences },
                      setter: { newItem in AppControllers.shared.preferences.menuBar.schedulePreferences = newItem })
    }
}

extension MenuBarPreferences: Codable {
    private enum CodingKeys: String, CodingKey {
        case showInMenuBar
        case showCountDown
        case blink
        case countDownFormat
        case schedulePreferences
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.showInMenuBar = try values.decodeIfPresent(Bool.self, forKey: .showInMenuBar) ?? Self.default.showInMenuBar
        self.showCountDown = try values.decodeIfPresent(Bool.self, forKey: .showCountDown) ?? Self.default.showCountDown
        self.blink = try values.decodeIfPresent(Bool.self, forKey: .blink) ?? Self.default.blink
        self.countDownFormat = try values.decodeIfPresent(CountDownFormat.self, forKey: .countDownFormat) ?? Self.default.countDownFormat
        SchedulePreferences.defaults = Self.default.schedulePreferences
        self.schedulePreferences = try values.decodeIfPresent(SchedulePreferences.self, forKey: .schedulePreferences) ??
                                        Self.default.schedulePreferences
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.showInMenuBar, forKey: .showInMenuBar)
        try container.encode(self.showCountDown, forKey: .showCountDown)
        try container.encode(self.blink, forKey: .blink)
        try container.encode(self.countDownFormat, forKey: .countDownFormat)
        try container.encode(self.schedulePreferences, forKey: .schedulePreferences)
    }
}
