//
//  AppIconController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 4/7/21.
//

import AppKit
import Foundation
import RoosterCore

public class AppIconController: AlarmNotificationControllerDelegate, Loggable {
    private var userAttentionRequest: Int?

    public init() {
        CoreControllers.shared.alarmNotificationController.delegate = self
    }

    public var shouldBounceIcon: Bool {
        AppControllers.shared.preferences.notifications.notificationPreferencesForAppState.options.contains(.bounceAppIcon)
    }

    public var isBouncing: Bool {
        self.userAttentionRequest != nil
    }

    public func startBouncingAppIcon() {
        guard self.isBouncing == false else {
            return
        }

        if self.shouldBounceIcon {
            let userAttentionRequest = NSApp.requestUserAttention(.criticalRequest)
            if userAttentionRequest >= 0 {
                self.userAttentionRequest = userAttentionRequest
                self.logger.log("Started bouncing icon for userAttentionRequest: \(userAttentionRequest)")
            } else {
                self.logger.log("App is already active, not bouncing")
            }
        }
    }

    public func stopBouncingAppIcon() {
        if let userAttentionRequest = self.userAttentionRequest {
            self.logger.log("Stopping bouncing icon for userAttentionRequest: \(userAttentionRequest)")
            NSApp.cancelUserAttentionRequest(userAttentionRequest)
            self.userAttentionRequest = nil
        }
    }

    public func alarmNotificationControllerAlarmsDidUpdate(_ controller: AlarmNotificationController) {
        if controller.alarmsAreFiring {
            self.startBouncingAppIcon()
        } else {
            self.stopBouncingAppIcon()
        }
    }

    public func alarmNotificationController(_ controller: AlarmNotificationController,
                                            alarmNotificationDidStart alarm: AlarmNotification) {
    }

    public func alarmNotificationController(_ controller: AlarmNotificationController,
                                            alarmNotificationDidFinish alarm: AlarmNotification) {
    }
}
