//
//  NotificationController.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation
import UserNotifications

public class UserNotificationCenterController : NSObject, UNUserNotificationCenterDelegate, Loggable {
    
    private var identifiers:Set<String>
    private let timer: SimpleTimer
    private var accessGranted: Bool
    
    var systemNotificationDelay: TimeInterval = 7.0
    
    public override init() {
        self.accessGranted = false
        self.identifiers = Set<String>()
        self.timer = SimpleTimer(withName: "UserNotificationRescheduleTimer")
        
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    public func requestAccess(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge, .providesAppNotificationSettings, .provisional]) { granted, error in
            
            if let error = error {
                self.logger.error("Requesting notification access failed with error: \(error.localizedDescription)")
                
                completion(false, error)
            } else {
                self.logger.log("Granted access to userNotifications")
                self.accessGranted = true
                
                completion(true, nil)
            }
            
        
        }
    }
    
    public func scheduleNotification(forItem item: RCCalendarItem) -> String {

        let notifID = item.id
        
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            guard (settings.authorizationStatus == .authorized) ||
                  (settings.authorizationStatus == .provisional) else { return }
        
           let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            let content = UNMutableNotificationContent()
            content.title = item.title
            
            if  let startDate = item.alarm.startDate,
                let endDate = item.alarm.endDate {
                content.body = "\(startDate.shortTimeString) - \(endDate.shortTimeString)"
            }
            
            if settings.alertSetting == .enabled {
                // Schedule an alert-only notification.
            }
            
            if settings.badgeSetting == .enabled {
                content.badge = 1
            }
            
            content.userInfo = ["item-id": item.id]
        
            self.identifiers.insert(notifID)

            // FIXME
            #if targetEnvironment(macCatalyst)
            UIApplication.shared.applicationIconBadgeNumber = self.identifiers.count
            #endif
            
            let request = UNNotificationRequest(identifier: notifID,
                                                content: content,
                                                trigger: trigger)

            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
                if error != nil {
                    self.logger.error("Error scheduling notification: \(error?.localizedDescription ?? "")")
                } else if self.identifiers.contains(notifID) {
                    let delay = self.systemNotificationDelay
                    
                    self.logger.log("Scheduled notification ok, will fire again in \(delay) seconds")
                    
                    self.timer.start(withInterval: delay) { timer in
                        if self.identifiers.contains(notifID) {
                            self.logger.log("User notification rescheduler timer fired after delay of \(delay) seconds")
                            if self.identifiers.count > 0 {
                                _ = self.scheduleNotification(forItem: item)
                            }
                        } else {
                            self.logger.log("\(notifID) was removed, stopping notifications.")
                        }
                    }
                } else {
                    self.logger.log("\(notifID) was removed, stopping notifications.")
                }
            }
        }
        
        return notifID
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
    
    public func cancelNotifications(forItemIdentifier itemID: String) {
        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: [itemID])
        center.removePendingNotificationRequests(withIdentifiers: [itemID])

        if self.identifiers.contains(itemID) {
            self.identifiers.remove(itemID)
        }
        
        // FIXME
        #if targetEnvironment(macCatalyst)
        UIApplication.shared.applicationIconBadgeNumber = self.identifiers.count
        #endif

        self.logger.log("Cancelled user notification for item: \(itemID)")
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
