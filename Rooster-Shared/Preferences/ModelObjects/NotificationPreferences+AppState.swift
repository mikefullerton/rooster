//
//  NotificationPreferences+AppState.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore


extension NotificationPreferences {
    
    var notificationPreferencesForAppState: SingleNotificationPreference {
        
        var preferencesKey = NotificationPreferences.PreferenceKey.normal
        
        let deviceInspector = DeviceInspector()
        
        if deviceInspector.systemIsLockedOrAsleep {
            self.logger.log("machine locked!")
            preferencesKey = .machineLockedOrAsleep
        }
        
        #if false
        if preferencesKey == .normal {
            let cameraIsOn = deviceInspector.hasBusyCoreMediaDevices
            
            if cameraIsOn {
                preferencesKey = .cameraOrMicrophoneOn
            }
        
            self.logger.log("found running camera: \(cameraIsOn)")
        }
        
        if preferencesKey == .normal {
            let foundActiveMicrophone = deviceInspector.hasBusyAudioInputDevices
            
            if foundActiveMicrophone {
                preferencesKey = .cameraOrMicrophoneOn
            }
        
            self.logger.log("found active microphone: \(foundActiveMicrophone)")
        }
        #endif
        
        self.logger.log("chose pref key: \(preferencesKey.description)")
        
        return self.preference(forKey: preferencesKey)
    }
    
}
