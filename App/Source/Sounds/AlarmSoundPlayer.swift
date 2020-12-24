//
//  AlarmManager.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import AVFoundation
//
//protocol AlarmSoundPlayerDelegate : AnyObject {
//    func alarmSoundPlayer( _ player: AlarmSoundPlayer, soundWillStartPlaying sound: AlarmSound, forItem item: Alarmable)
//    
//    func alarmSoundPlayer( _ player: AlarmSoundPlayer, soundDidStopPlaying sound: AlarmSound, forItem item: Alarmable)
//    
//    func alarmSoundPlayerWillStartPlayingSounds(_ player: AlarmSoundPlayer)
//    
//    func alarmSoundPlayerDidStopPlayingSounds(_ player: AlarmSoundPlayer)
//}
//
//class AlarmSoundPlayer: AlarmSoundDelegate, Loggable, DataModelAware  {
//
//    weak var delegate: AlarmSoundPlayerDelegate?
//
//    private var playingSounds:[String: (item: Alarmable, sound: AlarmSound)]
//
//    static let instance = AlarmSoundPlayer()
//    
//    private var dataModelReloader : DataModelReloader?
//    
//    private init() {
//        self.playingSounds = [:]
//        self.dataModelReloader = DataModelReloader(for: self)
//        
//        do {
//            let audioSession = AVAudioSession.sharedInstance()
//            try audioSession.setCategory(.playback, mode: .default)
//            try audioSession.setActive(true)
//            AlarmSoundPlayer.logger.log("Configured audio session ok")
//        } catch let error {
//            AlarmSoundPlayer.logger.error("Configuring AVAudioSession failed with error: \(error.localizedDescription)")
//        }
//    }
//        
//    func soundWillStartPlaying(_ sound: AlarmSound, forIdentifier identifier: String) {
//        if let delegate = self.delegate,
//           let pair = self.playingSounds[identifier] {
//            delegate.alarmSoundPlayer(self, soundWillStartPlaying:pair.sound, forItem: pair.item)
//        }
//    }
//    
//    func soundDidStopPlaying(_ sound: AlarmSound) {
//        if let pair = self.playingSounds[sound.behavior.identifier] {
//            self.playingSounds.removeValue(forKey: sound.behavior.identifier)
//            self.logger.log("Stopped alarm sound: \(pair.sound.name) for \(pair.item.title)")
//
//            if let delegate = self.delegate {
//                delegate.alarmSoundPlayer(self, soundDidStopPlaying:pair.sound, forItem: pair.item)
//                
//                if self.playingSounds.count == 0 {
//                    delegate.alarmSoundPlayerDidStopPlayingSounds(self)
//                }
//            }
//        }
//    }
//
//    func startPlayingSound(forItem item: Alarmable) -> Bool {
//        if self.isPlayingSound(forItem: item) {
//            return false
//        }
//        
//        if self.playingSounds.count == 0,
//           let delegate = self.delegate {
//            delegate.alarmSoundPlayerWillStartPlayingSounds(self)
//        }
//
//        let alarmSound = self.sound(forItem: item)
//        
//        let soundBehavior = AlarmSoundBehavior(withIdentifier: item.id,
//                                               playCount: AlarmSoundBehavior.RepeatEndlessly,
//                                               timeBetweenPlays: 0.1,
//                                               fadeInTime: 0)
//        
//        alarmSound.delegate = self
//        
//        self.playingSounds[item.id] = (item: item, sound: alarmSound)
//        self.logger.log("Started alarm sound: \(alarmSound.name) for \(item.title)")
//
//        alarmSound.play(withBehavior: soundBehavior)
//        return true
//    }
//    
//    func isPlayingSound(forItem item: Alarmable) -> Bool  {
//        return self.playingSounds[item.id] != nil
//    }
//    
//    func stopPlayingSound(forItem item: Alarmable) {
//        if let pair = self.playingSounds[item.id] {
//            self.playingSounds.removeValue(forKey: item.id)
//            pair.sound.delegate = nil
//            pair.sound.stop()
//            self.logger.log("Stopped alarm sound: \(pair.sound.name) for \(item.title)")
//        
//            if let delegate = self.delegate {
//                delegate.alarmSoundPlayer(self, soundDidStopPlaying:pair.sound, forItem: pair.item)
//                
//                if self.playingSounds.count == 0 {
//                    delegate.alarmSoundPlayerDidStopPlayingSounds(self)
//                }
//            }
//        }
//    }
//    
//    var playingCount: Int {
//        return self.playingSounds.count
//    }
//    
//    private func sound(forItem item: Alarmable) -> AlarmSound {
//        let preference = PreferencesController.instance.soundPreference(forItem: item)
//        let alarmSound = AlarmSoundGroup(withPreference: preference)
//        return alarmSound
//    }
//
//    func dataModelDidReload(_ dataModel: EventKitDataModel) {
//        for event in dataModel.events {
//            if let pair = self.playingSounds[event.id] {
//                self.playingSounds[event.id] = (item: event, sound: pair.sound)
//
//                self.logger.log("Updated playing sound for event: \(event)")
//            }
//        }
//        
//        for reminder in dataModel.reminders {
//            if let pair = self.playingSounds[reminder.id] {
//                self.playingSounds[reminder.id] = (item: reminder, sound: pair.sound)
//                
//                self.logger.log("Updated playing sound for reminder: \(reminder)")
//            }
//        }
//    }
//}
//
