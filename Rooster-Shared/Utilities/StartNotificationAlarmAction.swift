//
//  NotificationsAlarmAction.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/17/21.
//

import Foundation
import RoosterCore

public class StartNotificationAlarmAction: AlarmNotificationAction {
    private var notificationID: String?

    override public func startAction() {
        if let scheduleItem = self.scheduleItem,
            !self.alarmState.contains(.notificationsStarted) {
            self.alarmState += .notificationsStarted

            let prefs = AppControllers.shared.preferences.notifications.notificationPreferencesForAppState

            if prefs.options.contains(.autoOpenLocations),
                scheduleItem.openLocationURL() {
                self.logger.log("auto opening location URL (if available) for \(self.description)")

                scheduleItem.bringLocationAppsToFront()
            }

            if prefs.options.contains(.useSystemNotifications) {
                let notifID = CoreControllers.shared.userNotificationController.scheduleNotificationIfAuthorized(forItem: scheduleItem)
                self.notificationID = notifID
                self.logger.log("posted system notifications for \(self.description), notifID: \(notifID ?? "not found")")
            }

            // not waiting on anything, so mark this as done
            self.setFinished()
        }
    }

    override public func stopAction() {
        if !self.alarmState.contains(.notificationsFinished) {
            self.alarmState += .notificationsFinished

            self.logger.log("Stopping notifications for calendarItem: \(self.description)")

            if let notifID = self.notificationID {
                self.logger.log("Stopping notification for itemID: \(notifID)")
                CoreControllers.shared.userNotificationController.cancelNotifications(forNotificationID: notifID)
                self.notificationID = nil
            }
        }
    }
}
