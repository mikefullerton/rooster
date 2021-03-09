//
//  CalendarPreferences.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/25/21.
//

import Foundation
import RoosterCore

public struct CalendarPreferences: CustomStringConvertible, Loggable, Equatable {
    public var options: Options

    public var scheduleBehavior: CalendarScheduleBehavior

    public static let `default` = CalendarPreferences()

    public init() {
        self.options = .zero
        self.scheduleBehavior = CalendarScheduleBehavior()
    }

    public var description: String {
        """
        "\(type(of: self)): \
        Options: \(self.options.description), \
        schedule behavior: \(scheduleBehavior.description)
        """
    }
}

extension CalendarPreferences: Codable {
    private enum CodingKeys: String, CodingKey {
        case options
        case scheduleBehavior
    }

    public init(from decoder: Decoder) throws {
        let defaults = Self.default

        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.options = try values.decodeIfPresent(Options.self, forKey: .options) ?? defaults.options
        self.scheduleBehavior = try values.decodeIfPresent(CalendarScheduleBehavior.self, forKey: .scheduleBehavior) ?? defaults.scheduleBehavior
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.options, forKey: .options)
        try container.encode(self.scheduleBehavior, forKey: .scheduleBehavior)
    }
}

extension CalendarPreferences {
    public struct Options: DescribeableOptionSet {
        public let rawValue: Int

        public static var zero                 = Options([])
        public static let showCalendarName     = Options(rawValue: 1 << 1)

        public static let all: Options = [ .showCalendarName ]

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static var descriptions: [(Self, String)] = [
            ( .showCalendarName, "showCalendarName")
        ]
    }
}
