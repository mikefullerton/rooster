//
//  EventPreferences.swift
//  RoosterCore-macOS
//
//  Created by Mike Fullerton on 3/26/21.
//

import Foundation
import RoosterCore

public struct EventPreferences: Equatable, CustomStringConvertible {
    public var scheduleBehavior: EventScheduleBehavior

    public var description: String {
        """
        \(type(of: self)): \
        scheduleBehavior: \(scheduleBehavior.description)
        """
    }

    public static let `default` = EventPreferences()

    public init() {
        self.scheduleBehavior = EventScheduleBehavior()
    }
}

extension EventPreferences: Codable {
    private enum CodingKeys: String, CodingKey {
        case scheduleBehavior
    }

    public init(from decoder: Decoder) throws {
        let defaults = Self.default

        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.scheduleBehavior = try values.decodeIfPresent(EventScheduleBehavior.self, forKey: .scheduleBehavior) ?? defaults.scheduleBehavior
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.scheduleBehavior, forKey: .scheduleBehavior)
    }
}
