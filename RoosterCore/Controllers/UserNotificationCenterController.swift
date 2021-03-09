//
//  NotificationController.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//
import AppKit
import Foundation
import UserNotifications

public class UserNotificationCenterController: NSObject, Loggable {
    private var identifiers: Set<String>
    private let timer: SimpleTimer
    private var accessGranted: Bool

    public var systemNotificationDelay: TimeInterval = 7.0

    override public init() {
        self.accessGranted = false
        self.identifiers = Set<String>()
        self.timer = SimpleTimer(withName: "UserNotificationRescheduleTimer")
        super.init()

        UNUserNotificationCenter.current().delegate = self
    }

    public func requestAccess(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge, .providesAppNotificationSettings, .provisional]) { _, error in
            if let error = error {
                self.logger.error("Requesting notification access failed with error: \(String(describing: error))")

                completion(false, error)
            } else {
                self.logger.log("Granted access to userNotifications")
                self.accessGranted = true

                completion(true, nil)
            }
        }
    }

    public func scheduleNotificationIfAuthorized(forItem item: ScheduleItem) -> String? {
        guard item.alarm != nil else {
            return nil
        }

        let notifID = item.id

        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self = self else { return }

            guard (settings.authorizationStatus == .authorized) || (settings.authorizationStatus == .provisional) else {
                self.logger.log("Not authorized for notifications")
                return
            }

            self.logger.log("""
                starting user notifiction for item: \(notifID), \
                badgeSetting: \(String(describing: settings.badgeSetting.rawValue)), \
                alertSetting: \(String(describing: settings.alertSetting.rawValue))
                """)

            if settings.alertSetting == .enabled {
                // Schedule an alert-only notification.
            }

            if settings.badgeSetting == .enabled {
                // Show badge
            }

            self.scheduleNotification(withNotificationID: notifID,
                                      scheduleItem: item,
                                      withBadge: settings.badgeSetting == .enabled)
        }

        return notifID
    }

    public func cancelAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()

        self.identifiers = []
        self.timer.stop()

        NSApp.dockTile.badgeLabel = nil

        self.logger.log("Cancelled all user notifications")
    }

    public func cancelNotifications(forNotificationID notifID: String) {
        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: [notifID])
        center.removePendingNotificationRequests(withIdentifiers: [notifID])

        if self.identifiers.contains(notifID) {
            self.identifiers.remove(notifID)
        }

        if NSApp.dockTile.badgeLabel != nil {
            self.updateBadge()
        }

        self.logger.log("Cancelled user notification for item: \(notifID)")
    }

    private func updateBadge() {
        DispatchQueue.main.async {
            if !self.identifiers.isEmpty {
                NSApp.dockTile.badgeLabel = "\(self.identifiers.count)"
            } else {
                NSApp.dockTile.badgeLabel = nil
            }
        }
    }
}

extension UserNotificationCenterController: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       openSettingsFor notification: UNNotification?) {
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        self.logger.log("User tapped a notification, stopping everything...")
        self.cancelAllNotifications()
        CoreControllers.shared.alarmNotificationController.stopAllNotifications(bringNotificationAppsForward: true)
        completionHandler()
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completion: @escaping (UNNotificationPresentationOptions) -> Void) {
        completion([.badge, .banner, .sound])
    }
}

extension UserNotificationCenterController {
    fileprivate func createNotifictionRequest(withNotificationID notifID: String,
                                              scheduleItem: ScheduleItem) -> UNNotificationRequest? {
        guard let alarm = scheduleItem.alarm else {
            assertionFailure("alarm is nil")
            self.logger.error("alarm should not be nil here")
            return nil
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let content = UNMutableNotificationContent()
        content.title = scheduleItem.title

        let startDate = alarm.dateRange.startDate
        let endDate = alarm.dateRange.endDate
        content.body = "\(startDate.shortTimeString) - \(endDate.shortTimeString)"

        content.userInfo = ["item-id": notifID]

        let request = UNNotificationRequest(identifier: notifID,
                                            content: content,
                                            trigger: trigger)

        return request
    }

    fileprivate func scheduleNotification(withNotificationID notifID: String,
                                          scheduleItem item: ScheduleItem,
                                          withBadge: Bool) {
        guard let request = self.createNotifictionRequest(withNotificationID: notifID,
                                                          scheduleItem: item) else {
            self.logger.error("failed to create notification request \(notifID) for calendar item: \(item.description)")
            return
        }

        if withBadge {
            self.updateBadge()
        }

        self.logger.log("Scheduling notification \(notifID) for \(item.description)")
        self.identifiers.insert(notifID)

        UNUserNotificationCenter.current().add(request) { [weak self] error in
            guard let self = self else { return }

            if error != nil {
                self.identifiers.remove(notifID)
                self.logger.error("""
                    Error scheduling notification \(notifID), \
                    item: \(item.description), \
                    error: \(String(describing: error))
                    """)
            } else if self.identifiers.contains(notifID) {
                let delay = self.systemNotificationDelay

                self.logger.log("Scheduled notification ok, will fire again in \(delay) seconds")

                self.timer.start(withInterval: delay) { [weak self] _ in
                    guard let self = self else { return }
                    self.logger.log("User notification rescheduler timer fired after delay of \(delay) seconds")
                    self.timerDidFire(withNotificationID: notifID, scheduleItem: item, withBadge: withBadge)
                }
            } else {
                self.logger.log("\(notifID) was removed, stopping notifications.")
            }
        }
    }

    fileprivate func timerDidFire(withNotificationID notifID: String,
                                  scheduleItem item: ScheduleItem,
                                  withBadge: Bool) {
        if self.identifiers.contains(notifID) {
            self.scheduleNotification(withNotificationID: notifID,
                                      scheduleItem: item,
                                      withBadge: withBadge)
        } else {
            self.logger.log("\(notifID) was removed for item \(item.description), stopping notifications.")
            self.cancelNotifications(forNotificationID: notifID)
        }
    }
}
