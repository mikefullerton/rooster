//
//  SingleNotificationPreference.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/2/21.
//

import Foundation
import RoosterCore


public struct SingleNotificationPreference: CustomStringConvertible, Codable {
        
    public var systemNotificationDelay: TimeInterval  {
        didSet { self.updateTimestamp() }
    }
    
    public var options: Options {
        didSet { self.updateTimestamp() }
    }
    
    public var userActivityTimeout: TimeInterval {
        didSet { self.updateTimestamp() }
    }
    
    private var timestamp: Date
    
    public init(withOptions options: Options,
                systemNotificationDelay: TimeInterval,
                userActivityTimeout: TimeInterval) {
        
        self.timestamp = Date()
        self.options = options
        self.systemNotificationDelay = systemNotificationDelay
        self.userActivityTimeout = userActivityTimeout
    }

    private init() {
        self.systemNotificationDelay = 0
        self.options = []
        self.userActivityTimeout = 0
        self.timestamp = Date()
    }
    
    private mutating func updateTimestamp() {
        self.timestamp = Date()
    }
        
    public var description: String {
        return """
        \(type(of: self)): \
        timestamp: \(self.timestamp.shortDateAndLongTimeString), \
        options: \(self.options), \
        system notification delay: \(self.systemNotificationDelay), \
        user activity timeout: \(self.userActivityTimeout)
        """
    }
}

extension SingleNotificationPreference {
    public static let defaultSystemNotificationDelay: TimeInterval = 7.0
    
    public static let defaultUserActivityTimeoutInMinutes: TimeInterval = 15.0
}

extension SingleNotificationPreference {
    
    public struct Options: OptionSet, CustomStringConvertible, Codable {
        public let rawValue: Int
        
        public static let useSystemNotifications           = Options(rawValue: 1 << 1)
        public static let bounceAppIcon                    = Options(rawValue: 1 << 2)
        public static let autoOpenLocations                = Options(rawValue: 1 << 3)
        public static let disableAfterNoUserActivity       = Options(rawValue: 1 << 4)
        public static let playSounds                       = Options(rawValue: 1 << 5)

        public static let all:Options = [
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
            (.disableAfterNoUserActivity, "playSounds"),
        ]

        public var description: String {
            let result: [String] = Self.descriptions.filter { contains($0.0) }.map { $0.1 }
            return "\(type(of:self)): (rawValue: \(self.rawValue)) [\(result.joined(separator:", "))]"
        }
    }
}
