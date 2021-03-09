//
//  NotificationsAlarmAction.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/17/21.
//

import Foundation
import RoosterCore

class StartNotificationAlarmAction: AlarmNotificationAction {
    
    var notificationID: String?
    
    #if os(macOS)
    var userAttentionRequest:Int?
    
    public func startBouncingAppIcon() {
        self.stopBouncingAppIcon()
        let userAttentionRequest = NSApp.requestUserAttention(.criticalRequest)
        self.userAttentionRequest = userAttentionRequest
        self.logger.log("Started bouncing icon for userAttentionRequest: \(userAttentionRequest)")
      
    }
    
    public func stopBouncingAppIcon() {
        if let userAttentionRequest = self.userAttentionRequest {
            self.logger.log("Stopping bouncing icon for userAttentionRequest: \(userAttentionRequest)")
            NSApp.cancelUserAttentionRequest(userAttentionRequest)
            self.userAttentionRequest = nil
        }
    }
    #endif
    
    public override func startAction() {
        if let calendarItem = self.calendarItem,
            !self.alarmState.contains(.notificationsStarted) {
            
            self.alarmState += .notificationsStarted
                       
            let prefs = Controllers.preferencesController.notificationPreferences.notificationPreferencesForAppState
            
            if prefs.options.contains(.autoOpenLocations),
                calendarItem.openLocationURL() {
                    self.logger.log("auto opening location URL (if available) for \(self.description)")
                
                calendarItem.bringLocationAppsToFront()
            }
            
            if prefs.options.contains(.useSystemNotifications) {
            
                let notifID = Controllers.userNotificationController.scheduleNotification(forItem: calendarItem)
                self.notificationID = notifID
                self.logger.log("posted system notifications for \(self.description), notifID: \(notifID)")
            }
            
            #if os(macOS)
            self.startBouncingAppIcon()
            #endif
                
            // not waiting on anything, so mark this as done
            self.setFinished()
        }
    }
    
    public override func stopAction() {
        
        if !self.alarmState.contains(.notificationsFinished) {
            self.alarmState += .notificationsFinished
        
            self.logger.log("Stopping notifications for calendarItem: \(self.description)")
            #if os(macOS)
            self.stopBouncingAppIcon()
            #endif

            if let notifID = self.notificationID {
                self.logger.log("Stopping notification for itemID: \(notifID)")
                Controllers.userNotificationController.cancelNotifications(forItemIdentifier: notifID)
                self.notificationID = nil
            }
        }
        
    }
}
