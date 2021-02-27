//
//  AlarmStartActions.swift
//  RoosterCoreTests
//
//  Created by Mike Fullerton on 2/27/21.
//

import Foundation
import RoosterCore

class StartNotificationAlarmAction: AlarmNotificationStartAction {
    
    func alarmNotificationStartAction(_ alarmNotification: AlarmNotification) {
        if let item = alarmNotification.item {
            alarmNotification.logger.log("performing start actions for \(alarmNotification.description)")
            
            let prefs = Controllers.preferencesController.notificationPreferences
            
            if prefs.options.contains(.autoOpenLocations) {
                alarmNotification.logger.log("auto opening location URL (if available) for \(alarmNotification.description)")
                
                item.openLocationURL()
                item.bringLocationAppsToFront()
            }
            
            if prefs.options.contains(.useSystemNotifications) {
                alarmNotification.logger.log("posting system notifications for \(alarmNotification.description)")

                Controllers.userNotificationController.scheduleNotification(forItem: item)
            }
            
            #if os(macOS)
            
            if prefs.options.contains(.bounceAppIcon) {
                alarmNotification.logger.log("bouncing app in dock for \(alarmNotification.description)")

                Controllers.systemUtilities.startBouncingAppIcon()
            }
            
            #endif
            
            #if targetEnvironment(macCatalyst)
            if prefs.bounceIconInDock {
                alarmNotification.logger.log("bouncing app in dock for \(alarmNotification.description)")

                Controllers.appKitPlugin.utilities.startBouncingAppIcon()
            }
            #endif
        }
    }
    
    func alarmNotificationStopAction(_ alarmNotification: AlarmNotification) {
        
    }
}

class StartPlayingSoundAlarmAction: AlarmNotificationStartAction {

    private let timer: SimpleTimer
    private var sound: Sound?
    
    init() {
        self.timer = SimpleTimer(withName: "AlarmNotificationTimer")
        self.sound = nil
    }
    
    func alarmNotificationStartAction(_ alarmNotification: AlarmNotification) {

        let soundPrefs = Controllers.preferencesController.preferences(forItemIdentifier: alarmNotification.itemID).soundPreference
        
        guard soundPrefs.hasEnabledSoundPreferences else {
            alarmNotification.logger.log("sounds disabled not playing sound")
            return
        }
        
        let iterator = soundPrefs.allSoundsIterator
       
        guard iterator.sounds.count > 0 else {
            alarmNotification.logger.log("No sounds in iterators to play")
            return
        }
        
       //        return
        let sound = PlayList(withPlayListIterator: iterator, displayName: "")
        sound.delegate = alarmNotification
        
        self.sound = sound
        
        let soundBehavior = SoundBehavior(playCount: soundPrefs.playCount,
                                               timeBetweenPlays: 0.1,
                                               fadeInTime: 0)
        
        let interval = TimeInterval(soundPrefs.startDelay)
        
         alarmNotification.logger.log("starting alarm sound for \(alarmNotification.description), with interval: \(interval)")

         self.timer.start(withInterval:interval) { (timer) in
            
             alarmNotification.logger.log("playing alarm sound: \(sound.displayName) for \(alarmNotification.description)")

             sound.play(withBehavior: soundBehavior)
         }
    }
    
    func alarmNotificationStopAction(_ alarmNotification: AlarmNotification) {
        self.timer.stop()
        
        if let sound = self.sound {
            sound.stop()
        }
    }
}

extension AlarmNotification {
    public static func setAlarmStartActionsFactory() {
        Self.startActionsFactory = {
            return [ StartNotificationAlarmAction(), StartPlayingSoundAlarmAction() ]
        }
    }
}
