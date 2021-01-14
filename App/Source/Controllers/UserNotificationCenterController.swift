//
//  NotificationController.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation
import UIKit

class UserNotificationCenterController : NSObject, UNUserNotificationCenterDelegate, Loggable {
    
    static var instance = UserNotificationCenterController()
    
    private var identifiers:[String]
    private let timer: SimpleTimer
    private var accessGranted: Bool
    
    private override init() {
        self.accessGranted = false
        self.identifiers = []
        self.timer = SimpleTimer(withName: "UserNotificationRepeatTimer")
        
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestAccess() {
        let center = UNUserNotificationCenter.current()
        // , .provisional
//        UNAuthorizationOptionProvidesAppNotificationSettings
        center.requestAuthorization(options: [.alert, .sound, .badge, .providesAppNotificationSettings]) { granted, error in
            
            if let error = error {
                self.logger.error("Requesting notification access failed with error: \(error.localizedDescription)")
            } else {
                self.logger.log("Granted access")
                self.accessGranted = true
            }
        }
    }
    
    func scheduleNotification(forItem item: CalendarItem) {

        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            guard (settings.authorizationStatus == .authorized) ||
                  (settings.authorizationStatus == .provisional) else { return }
        
            let uuidString = UUID().uuidString
            
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
            
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = 1
            }
            
            content.userInfo = ["item-id": item.id]
        
            self.identifiers.append(uuidString)
        
            let request = UNNotificationRequest(identifier: uuidString,
                                                content: content,
                                                trigger: trigger)

            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
                if error != nil {
                    self.logger.error("Error scheduling notification: \(error?.localizedDescription ?? "")")
                } else {
                    self.logger.log("Scheduled notification ok")
                    
                    self.timer.start(withInterval: 7) { timer in
                        self.logger.log("Scheduler notification fired")
                        if self.identifiers.count > 0 {
                            self.scheduleNotification(forItem: item)
                        }
                    }
                }
            }
        }
    }
    
    func cancelNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        UIApplication.shared.applicationIconBadgeNumber = 0
        self.identifiers = []
        self.timer.stop()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                openSettingsFor notification: UNNotification?) {
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        AlarmNotificationController.instance.stopAllNotifications()
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .banner])
    }
}
