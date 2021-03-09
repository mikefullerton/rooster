//
//  SingleNotificationPreference.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/2/21.
//

import Foundation
import RoosterCore

public struct SingleNotificationPreference: CustomStringConvertible, Equatable {
    public var systemNotificationDelay: TimeInterval
    public var options: Options
    public var userActivityTimeout: TimeInterval

    public static let `default` = SingleNotificationPreference()

    public init(withOptions options: Options,
                systemNotificationDelay: TimeInterval,
                userActivityTimeout: TimeInterval) {
        self.options = options
        self.systemNotificationDelay = systemNotificationDelay
        self.userActivityTimeout = userActivityTimeout
    }

    public init() {
        self.init(withOptions: .all,
                  systemNotificationDelay: 7.0,
                  userActivityTimeout: 15.0)
    }

    public var description: String {
        """
        \(type(of: self)): \
        options: \(self.options), \
        system notification delay: \(self.systemNotificationDelay), \
        user activity timeout: \(self.userActivityTimeout)
        """
    }
}

extension SingleNotificationPreference: Codable {
    private enum CodingKeys: String, CodingKey {
        case systemNofificationDelay
        case options
        case userActivityTimeout
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.options = try values.decodeIfPresent(Options.self, forKey: .options) ?? Self.default.options
        self.systemNotificationDelay = try values.decodeIfPresent(TimeInterval.self, forKey: .systemNofificationDelay) ??
            Self.default.systemNotificationDelay
        self.userActivityTimeout = try values.decodeIfPresent(TimeInterval.self, forKey: .userActivityTimeout) ?? Self.default.userActivityTimeout
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.options, forKey: .options)
    }
}

extension SingleNotificationPreference {
    public struct Options: DescribeableOptionSet {
        public let rawValue: Int

        public static let zero                             = Options([])
        public static let useSystemNotifications           = Options(rawValue: 1 << 1)
        public static let bounceAppIcon                    = Options(rawValue: 1 << 2)
        public static let autoOpenLocations                = Options(rawValue: 1 << 3)
        public static let disableAfterNoUserActivity       = Options(rawValue: 1 << 4)
        public static let playSounds                       = Options(rawValue: 1 << 5)

        public static let all: Options = [
            .useSystemNotifications,
            .bounceAppIcon,
            .autoOpenLocations,
            .disableAfterNoUserActivity,
            .playSounds
        ]

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static var descriptions: [(Self, String)] = [
            (.useSystemNotifications, "systemNotification"),
            (.bounceAppIcon, "bounceAppIcon"),
            (.autoOpenLocations, "autoOpenLocation"),
            (.disableAfterNoUserActivity, "disableAfterNoUserActivity"),
            (.disableAfterNoUserActivity, "playSounds")
        ]
    }
}
