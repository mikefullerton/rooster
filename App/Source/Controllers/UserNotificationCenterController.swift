//
//  NotificationController.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation
import UIKit

class UserNotificationCenterController : NSObject, UNUserNotificationCenterDelegate, Loggable {
    
    private var identifiers:[String]
    private let timer: SimpleTimer
    private var accessGranted: Bool
    let preferencesController: PreferencesController
    
    init(preferencesController: PreferencesController) {
        self.accessGranted = false
        self.identifiers = []
        self.timer = SimpleTimer(withName: "UserNotificationRescheduleTimer")
        self.preferencesController = preferencesController
        
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestAccess() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge, .providesAppNotificationSettings, .provisional]) { granted, error in
            
            if let error = error {
                self.logger.error("Requesting notification access failed with error: \(error.localizedDescription)")
            } else {
                self.logger.log("Granted access to userNotifications")
                self.accessGranted = true
            }
        }
    }
    
    func scheduleNotification(forItem item: CalendarItem) {

        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            guard (settings.authorizationStatus == .authorized) ||
                  (settings.authorizationStatus == .provisional) else { return }
        
           let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            let content = UNMutableNotificationContent()
            content.title = item.title
            
            let endDate = item.alarm.endDate != nil ? " - \(item.alarm.endDate!.shortTimeString)" : ""
            
            content.body = "\(item.alarm.startDate.shortTimeString)\(endDate)"
            
            if settings.alertSetting == .enabled {
                // Schedule an alert-only notification.
            }
            
            if settings.badgeSetting == .enabled {
                content.badge = 1
            }
            
            content.userInfo = ["item-id": item.id]
        
            self.identifiers.append(item.id)

            UIApplication.shared.applicationIconBadgeNumber = self.identifiers.count
            
            let request = UNNotificationRequest(identifier: item.id,
                                                content: content,
                                                trigger: trigger)

            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
                if error != nil {
                    self.logger.error("Error scheduling notification: \(error?.localizedDescription ?? "")")
                } else {
                    let delay = self.preferencesController.preferences.systemNotificationDelay
                    
                    self.logger.log("Scheduled notification ok, will fire again in \(delay) seconds")
                    
                    self.timer.start(withInterval: delay) { timer in
                        self.logger.log("User notification rescheduler timer fired after delay of \(delay) seconds")
                        if self.identifiers.count > 0 {
                            self.scheduleNotification(forItem: item)
                        }
                    }
                }
            }
        }
    }
    
    func cancelAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        UIApplication.shared.applicationIconBadgeNumber = 0
        self.identifiers = []
        self.timer.stop()
        
        self.logger.log("Cancelled all user notifications")
    }
    
    func cancelNotifications(forItem item: CalendarItem) {
        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: [item.id])
        center.removePendingNotificationRequests(withIdentifiers: [item.id])

        if let index = self.identifiers.firstIndex(of: item.id) {
            self.identifiers.remove(at: index)
        }
        
        UIApplication.shared.applicationIconBadgeNumber = self.identifiers.count

        self.logger.log("Cancelled user notification for item: \(item.description)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                openSettingsFor notification: UNNotification?) {
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        self.logger.log("Notification received response")
        AppDelegate.instance.alarmNotificationController.stopAllNotifications(bringNotificationAppsForward: true)
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .banner, .sound])
    }
}
