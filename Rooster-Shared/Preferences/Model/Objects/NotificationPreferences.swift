//
//  NotificationPreferences.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

public struct NotificationPreferences: CustomStringConvertible, Loggable, Equatable {
    private var notificationPreferences: [SingleNotificationPreference]

    public static let `default` = NotificationPreferences()

    private init() {
        self.notificationPreferences = [
            SingleNotificationPreference(),
            SingleNotificationPreference(),
            SingleNotificationPreference()
        ]
    }

    public func preference(forKey key: PreferenceKey) -> SingleNotificationPreference {
        self.notificationPreferences[key.rawValue]
    }

    public mutating func setPreference(_ preference: SingleNotificationPreference, forKey key: PreferenceKey) {
        var prefs = self.notificationPreferences
        prefs[key.rawValue] = preference
        self.notificationPreferences = prefs
    }

    public var description: String {
        """
        \(type(of: self)): \
        notificationPreferences: \(self.notificationPreferences.map { $0.description }.joined(separator: ", "))
        """
    }
}

extension NotificationPreferences: Codable {
    private enum CodingKeys: String, CodingKey {
        case notificationPreferences
    }

    public init(from decoder: Decoder) throws {
        let defaults = Self.default
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.notificationPreferences = try values.decodeIfPresent([SingleNotificationPreference].self, forKey: .notificationPreferences) ??
                defaults.notificationPreferences
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.notificationPreferences, forKey: .notificationPreferences)
    }
}

extension NotificationPreferences {
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

extension NotificationPreferences {
    var notificationPreferencesForAppState: SingleNotificationPreference {
        var preferencesKey = NotificationPreferences.PreferenceKey.normal

        let deviceInspector = DeviceInspector()

        if deviceInspector.systemIsLockedOrAsleep {
            self.logger.log("machine locked!")
            preferencesKey = .machineLockedOrAsleep
        }

#if false
        if preferencesKey == .normal {
            let cameraIsOn = deviceInspector.hasBusyCoreMediaDevices

            if cameraIsOn {
                preferencesKey = .cameraOrMicrophoneOn
            }

            self.logger.log("found running camera: \(cameraIsOn)")
        }

        if preferencesKey == .normal {
            let foundActiveMicrophone = deviceInspector.hasBusyAudioInputDevices

            if foundActiveMicrophone {
                preferencesKey = .cameraOrMicrophoneOn
            }

            self.logger.log("found active microphone: \(foundActiveMicrophone)")
        }
#endif

        self.logger.log("chose pref key: \(preferencesKey.description)")

        return self.preference(forKey: preferencesKey)
    }
}
