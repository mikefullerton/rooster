//
//  NotificationController.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation
import UserNotifications

public class UserNotificationCenterController : NSObject, UNUserNotificationCenterDelegate, Loggable {
    
    private var identifiers:[String]
    private let timer: SimpleTimer
    private var accessGranted: Bool
    
    var systemNotificationDelay: TimeInterval = 7.0
    
    public override init() {
        self.accessGranted = false
        self.identifiers = []
        self.timer = SimpleTimer(withName: "UserNotificationRescheduleTimer")
        
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    public func requestAccess() {
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
    
    public func scheduleNotification(forItem item: RCCalendarItem) {

        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            guard (settings.authorizationStatus == .authorized) ||
                  (settings.authorizationStatus == .provisional) else { return }
        
           let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            let content = UNMutableNotificationContent()
            content.title = item.title
            
            let endDate = " - \(item.alarm.endDate.shortTimeString)" 
            
            content.body = "\(item.alarm.startDate.shortTimeString)\(endDate)"
            
            if settings.alertSetting == .enabled {
                // Schedule an alert-only notification.
            }
            
            if settings.badgeSetting == .enabled {
                content.badge = 1
            }
            
            content.userInfo = ["item-id": item.id]
        
            self.identifiers.append(item.id)

            // FIXME
            #if targetEnvironment(macCatalyst)
            UIApplication.shared.applicationIconBadgeNumber = self.identifiers.count
            #endif
            
            let request = UNNotificationRequest(identifier: item.id,
                                                content: content,
                                                trigger: trigger)

            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
                if error != nil {
                    self.logger.error("Error scheduling notification: \(error?.localizedDescription ?? "")")
                } else {
                    let delay = self.systemNotificationDelay
                    
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
    
    public func cancelAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        
        // FIXME
        #if targetEnvironment(macCatalyst)
        UIApplication.shared.applicationIconBadgeNumber = 0
        #endif
        
        self.identifiers = []
        self.timer.stop()
        
        self.logger.log("Cancelled all user notifications")
    }
    
    public func cancelNotifications(forItem item: RCCalendarItem) {
        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: [item.id])
        center.removePendingNotificationRequests(withIdentifiers: [item.id])

        if let index = self.identifiers.firstIndex(of: item.id) {
            self.identifiers.remove(at: index)
        }
        
        // FIXME
        #if targetEnvironment(macCatalyst)
        UIApplication.shared.applicationIconBadgeNumber = self.identifiers.count
        #endif

        self.logger.log("Cancelled user notification for item: \(item.description)")
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       openSettingsFor notification: UNNotification?) {
        
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        
        self.logger.log("Notification received response")
        Controllers.alarmNotificationController.stopAllNotifications(bringNotificationAppsForward: true)
        completionHandler()
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .banner, .sound])
    }
}
