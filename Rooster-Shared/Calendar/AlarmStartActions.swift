//
//  AlarmStartActions.swift
//  RoosterCoreTests
//
//  Created by Mike Fullerton on 2/27/21.
//

import Foundation
import RoosterCore

class StartNotificationAlarmAction: AlarmNotificationStartAction, Loggable {
    
    deinit {
        self.stopNotifications()
    }
    
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
    
    func alarmNotificationStartAction(_ alarmNotification: AlarmNotification) {
        if let item = alarmNotification.item {
            alarmNotification.logger.log("performing start actions for \(alarmNotification.description)")
            
            let prefs = Controllers.preferencesController.notificationPreferences.notificationPreferencesForAppState
            
            if prefs.options.contains(.autoOpenLocations),
                item.openLocationURL() {
                self.logger.log("auto opening location URL (if available) for \(alarmNotification.description)")
                
                item.bringLocationAppsToFront()
            }
            
            if prefs.options.contains(.useSystemNotifications) {
            
                let notifID = Controllers.userNotificationController.scheduleNotification(forItem: item)
                self.notificationID = notifID
                self.logger.log("posted system notifications for \(alarmNotification.description), notifID: \(notifID)")
}
            
            #if os(macOS)
            self.startBouncingAppIcon()
            #endif
        }
    }
    
    func alarmNotificationStopAction(_ alarmNotification: AlarmNotification) {
        self.logger.log("Stopping notifications for item: \(alarmNotification.description)")
        self.stopNotifications()
    }
    
    func stopNotifications() {
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

class StartPlayingSoundAlarmAction: AlarmNotificationStartAction, Loggable {

    private let timer: SimpleTimer
    private var playList: PlayList?
    
    init() {
        self.timer = SimpleTimer(withName: "AlarmNotificationTimer")
        self.playList = nil
    }
    
    deinit {
        self.playList?.stop()
    }
    
    func alarmNotificationStartAction(_ alarmNotification: AlarmNotification) {

        let prefs = Controllers.preferencesController.notificationPreferences.notificationPreferencesForAppState
        
        guard prefs.options.contains( .playSounds ) else {
            return
        }
        
        let soundPrefs = Controllers.preferencesController.preferences(forItemIdentifier: alarmNotification.itemID).soundPreference
        
        guard soundPrefs.hasEnabledSoundPreferences else {
            self.logger.log("sounds disabled not playing sound")
            return
        }
        
        let playList = soundPrefs.enabledPlayList
       
        guard !playList.isEmpty else {
            self.logger.log("No sounds in iterators to play")
            return
        }
        
        playList.delegate = alarmNotification
        
        self.playList = playList
        
        let soundBehavior = SoundBehavior(playCount: soundPrefs.playCount,
                                               timeBetweenPlays: 0.1,
                                               fadeInTime: 0)
        
        let interval = TimeInterval(soundPrefs.startDelay)
        
        self.logger.log("starting alarm sound for \(alarmNotification.description), with interval: \(interval)")

         self.timer.start(withInterval:interval) { (timer) in
            
             self.logger.log("playing alarm sounds playlist: \(playList.description) for \(alarmNotification.description)")

             playList.play(withBehavior: soundBehavior)
         }
    }
    
    func alarmNotificationStopAction(_ alarmNotification: AlarmNotification) {
        
        self.logger.log("Stopping sounds for alarm: \(alarmNotification.description)")
        self.timer.stop()
        self.playList?.stop()
        self.playList = nil
    }
}

extension AlarmNotification {
    public static func setAlarmStartActionsFactory() {
        Self.startActionsFactory = {
            return [ StartNotificationAlarmAction(), StartPlayingSoundAlarmAction() ]
        }
    }
}
