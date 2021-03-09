//
//  PlaySoundsNotificationAction.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/17/21.
//

import Foundation
import RoosterCore

public class StartPlayingSoundAlarmAction: AlarmNotificationAction, SoundDelegate {

    private let startDelayTimer: SimpleTimer = SimpleTimer(withName: "AlarmNotificationTimer")
    private var playList: PlayList?
    
    public override func startAction() {

        if !self.alarmState.contains( .soundsStarted) {
            
            self.alarmState += .soundsStarted
                
            let prefs = Controllers.preferences.notifications.notificationPreferencesForAppState
            
            guard prefs.options.contains( .playSounds ) else {
                return
            }
            
            let soundPrefs = Controllers.preferences.preferences(forItemIdentifier: self.itemID).soundPreference
            
            guard soundPrefs.hasEnabledSoundPreferences else {
                self.logger.log("sounds disabled not playing sound")
                return
            }
            
            let playList = soundPrefs.enabledPlayList
           
            guard !playList.isEmpty else {
                self.logger.log("No sounds in iterators to play")
                return
            }
            
            playList.delegate = self
            
            self.playList = playList
            
            let soundBehavior = SoundBehavior(playCount: soundPrefs.playCount,
                                              timeBetweenPlays: 0.1,
                                              fadeInTime: 0)
            
            let interval = TimeInterval(soundPrefs.startDelay)
            
            self.logger.log("starting alarm sound for \(self.description), with interval: \(interval)")

             self.startDelayTimer.start(withInterval:interval) { _ in
                
                 self.logger.log("playing alarm sounds playlist: \(playList.description) for \(self.description)")

                 playList.play(withBehavior: soundBehavior)
             }
        }
    }
    
    public override func stopAction() {
        
        if !self.alarmState.contains(.soundsFinished) {
            self.alarmState += .soundsFinished
        
            self.logger.log("Stopping sounds for alarm: \(self.description)")
            self.startDelayTimer.stop()
            
            if self.playList != nil {
                self.playList?.stop()
                self.playList = nil
            }
        }
    }
    
    public func soundWillStartPlaying(_ sound: SoundPlayerProtocol) {
    }
    
    public func soundDidStartPlaying(_ sound: SoundPlayerProtocol) {
    }

    public func soundDidUpdate(_ sound: SoundPlayerProtocol) {
    }

    public func soundDidStopPlaying(_ sound: SoundPlayerProtocol) {
        self.logger.log("alarm stopped playing sound: \(self.description)")
        self.stopAction()
        self.setFinished()
    }
    
}

