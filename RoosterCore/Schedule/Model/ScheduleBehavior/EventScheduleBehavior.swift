//
//  EventScheduleBehavior.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/10/21.
//

import Foundation

public struct EventScheduleBehavior: Equatable, CustomStringConvertible {
    public var showAllDayEvents: Bool
    public var showDeclinedEvents: Bool
    public var scheduleAllDayEvents: Bool

    public static let `default` = EventScheduleBehavior()

    public init(showAllDayEvents: Bool,
                showDeclinedEvents: Bool,
                scheduleAllDayEvents: Bool) {
        self.showAllDayEvents = showAllDayEvents
        self.showDeclinedEvents = showDeclinedEvents
        self.scheduleAllDayEvents = scheduleAllDayEvents
    }

    public init() {
        self.init(showAllDayEvents: true,
                  showDeclinedEvents: false,
                  scheduleAllDayEvents: false)
    }

    public var description: String {
        """
            \(type(of: self)): \
            allDay: \(self.showAllDayEvents), \
            declined: \(self.showDeclinedEvents), \
            scheduleAllDayEvents: \(self.scheduleAllDayEvents)
            """
    }
}

extension EventScheduleBehavior: Codable {
    private enum CodingKeys: String, CodingKey {
        case showAllDayEvents
        case showDeclinedEvents
        case scheduleAllDayEvents
    }

    public init(from decoder: Decoder) throws {
        let defaults = Self.default

        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.showAllDayEvents = try values.decodeIfPresent(Bool.self, forKey: .showAllDayEvents) ?? defaults.showAllDayEvents
        self.showDeclinedEvents = try values.decodeIfPresent(Bool.self, forKey: .showDeclinedEvents) ?? defaults.showDeclinedEvents
        self.scheduleAllDayEvents = try values.decodeIfPresent(Bool.self, forKey: .scheduleAllDayEvents) ?? defaults.scheduleAllDayEvents
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.showAllDayEvents, forKey: .showAllDayEvents)
        try container.encode(self.showDeclinedEvents, forKey: .showDeclinedEvents)
        try container.encode(self.scheduleAllDayEvents, forKey: .scheduleAllDayEvents)
    }
}
