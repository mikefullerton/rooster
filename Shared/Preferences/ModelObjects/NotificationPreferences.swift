//
//  NotificationPreferences.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/2/21.
//

import Foundation


struct NotificationPreferences: CustomStringConvertible {
    struct Options: OptionSet, CustomStringConvertible {
        let rawValue: Int
        
        static let useSystemNotifications   = Options(rawValue: 1 << 1)
        static let bounceAppIcon            = Options(rawValue: 1 << 2)
        static let autoOpenLocations        = Options(rawValue: 1 << 3)

        static let all:Options = [ .useSystemNotifications, .bounceAppIcon, .autoOpenLocations ]
        
        init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        static var descriptions: [(Self, String)] = [
            (.useSystemNotifications, "systemNotification"),
            (.bounceAppIcon, "bounceAppIcon"),
            (.autoOpenLocations, "autoOpenLocation"),
        ]

        var description: String {
            let result: [String] = Self.descriptions.filter { contains($0.0) }.map { $0.1 }
            return "\(type(of:self)): (rawValue: \(self.rawValue)) \(result)"
        }
    }

    static let defaultSystemNotificationDelay: TimeInterval = 7.0
    
    var systemNotificationDelay: TimeInterval
    var options: Options

    init(with options: Options,
         systemNotificationDelay: TimeInterval) {
        self.options = options
        self.systemNotificationDelay = systemNotificationDelay
    }
    
    init() {
        self.init(with: .all, systemNotificationDelay: Self.defaultSystemNotificationDelay)
    }
    
    var description: String {
        return "\(type(of: self)): \(self.options), system notification delay: \(self.systemNotificationDelay)"
    }
}

extension NotificationPreferences {
    
    enum CodingKeys: String, CodingKey {
        case options = "options"
        case systemNotificationDelay = "systemNotificationDelay"
    }
    
    init(withDictionary dictionary: [AnyHashable : Any]) {
    
        self.init()
        
        if let options = dictionary[CodingKeys.options.rawValue] as? Int {
            self.options = Options(rawValue: options)
        }
        
        if let delay = dictionary[CodingKeys.systemNotificationDelay.rawValue] as? TimeInterval {
            self.systemNotificationDelay = delay
        }
    }

    var asDictionary: [AnyHashable : Any] {
        var dictionary: [AnyHashable : Any] = [:]
        dictionary[CodingKeys.options.rawValue] = self.options.rawValue
        dictionary[CodingKeys.systemNotificationDelay.rawValue] = self.systemNotificationDelay
        return dictionary
    }
}
