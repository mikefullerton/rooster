//
//  NotificationPreferences.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

public struct NotificationPreferences: CustomStringConvertible, Loggable, Codable {
    
    private var timestamp: Date
   
    private var notificationPreferences: [SingleNotificationPreference] {
        didSet { self.updateTimestamp() }
    }
    
    private init() {
        self.notificationPreferences  = [
            SingleNotificationPreference(withOptions: .all,
                                         systemNotificationDelay: SingleNotificationPreference.defaultSystemNotificationDelay,
                                         userActivityTimeout: SingleNotificationPreference.defaultUserActivityTimeoutInMinutes),
            
            SingleNotificationPreference(withOptions: .all.subtracting([.playSounds, .autoOpenLocations]),
                                         systemNotificationDelay: SingleNotificationPreference.defaultSystemNotificationDelay,
                                         userActivityTimeout: SingleNotificationPreference.defaultUserActivityTimeoutInMinutes),
            
            SingleNotificationPreference(withOptions: [],
                                         systemNotificationDelay: SingleNotificationPreference.defaultSystemNotificationDelay,
                                         userActivityTimeout: SingleNotificationPreference.defaultUserActivityTimeoutInMinutes)
        ]

        self.timestamp = Date()
    }
    
    private mutating func updateTimestamp() {
        self.timestamp = Date()
    }
    
    public func preference(forKey key: PreferenceKey) -> SingleNotificationPreference {
        return self.notificationPreferences[key.rawValue]
    }
    
    public mutating func setPreference(_ preference: SingleNotificationPreference, forKey key: PreferenceKey) {
        var prefs = self.notificationPreferences
        prefs[key.rawValue] = preference
        self.notificationPreferences = prefs
    }

    public var description: String {
        return """
        type(of:self): \
        timestamp: \(self.timestamp.shortDateAndLongTimeString), \
        notificationPreferences: \(self.notificationPreferences.map { $0.description }.joined(separator: ", "))
        """
    }
}

extension NotificationPreferences {
    public static let `default` = NotificationPreferences()

    public enum PreferenceKey: Int, Codable, CaseIterable, CustomStringConvertible {
        case normal                         = 0
        case cameraOrMicrophoneOn           = 1
        case machineLockedOrAsleep          = 2
        
        public var description: String {
            switch self {
            case .normal:
                return "Normal Use"
                
            case .cameraOrMicrophoneOn:
                return "Camera or Microphone on"
                
            case .machineLockedOrAsleep:
                return "Computer Locked or Asleep"
            }
        }
    }


}
