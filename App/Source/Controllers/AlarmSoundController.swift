//
//  AlarmManager.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import OSLog

//protocol AlarmSoundManagerDelegate : AnyObject {
//    func alarmSoundManager(_ manager: AlarmSoundController, soundWillStartPlaying sound: AlarmSound)
//    func alarmSoundManager(_ manager: AlarmSoundController, soundDidStopPlaying sound: AlarmSound)
//}
//    weak var delegate: AlarmSoundManagerDelegate?

class AlarmSoundController: AlarmSoundDelegate  {

    static let logger = Logger(subsystem: "com.apple.rooster", category: "AlarmController")
    
    var logger: Logger {
        return AlarmSoundController.logger
    }

    private var firingEvents:[String: (item: Alarmable, sound: AlarmSound)]

    init() {
        self.firingEvents = [:]
    }
        
    func soundWillStartPlaying(_ sound: AlarmSound, forIdentifier identifier: String) {
    }
    
    func soundDidStopPlaying(_ sound: AlarmSound) {
        if let pair = self.firingEvents[sound.behavior.identifier] {
            self.firingEvents.removeValue(forKey: sound.behavior.identifier)
            self.logger.log("Stopped alarm sound: \(pair.sound.name) for \(pair.item.title)")
        }
    }
    
    func startPlayingSound(forItem item: Alarmable) {

        if self.isPlayingSound(forItem: item) {
            return
        }
        
        let preference = PreferencesController.instance.soundPreference(forItem: item)
        let alarmSound = AlarmSoundGroup(withPreference: preference)
    
        let soundBehavior = AlarmSoundBehavior(withIdentifier: item.id,
                                               playCount: AlarmSoundBehavior.RepeatEndlessly,
                                               timeBetweenPlays: 0.1,
                                               fadeInTime: 0)
        
        alarmSound.delegate = self
        alarmSound.play(withBehavior: soundBehavior)
        
        self.firingEvents[item.id] = (item: item, sound: alarmSound)

        self.logger.log("Started alarm sound: \(alarmSound.name) for \(item.title)")
    }
    
    func isPlayingSound(forItem item: Alarmable) -> Bool  {
        return self.firingEvents[item.id] != nil
    }
    
    func stopPlayingSound(forItem item: Alarmable) {
        
        if let pair = self.firingEvents[item.id] {
            self.firingEvents.removeValue(forKey: item.id)
            pair.sound.delegate = nil
            pair.sound.stop()
            self.logger.log("Stopped alarm sound: \(pair.sound.name) for \(item.title)")
        }
    }
    
    var playingCount: Int {
        return self.firingEvents.count
    }
    
    func visitPlayingSounds(_ visitor: (_ item: Alarmable, _ sound: AlarmSound) -> Void) {
        let firingEvents = self.firingEvents
        for (_, pair) in firingEvents {
            visitor(pair.item, pair.sound)
        }
    }
    
    func updateItemIfPlaying(_ item: Alarmable) {
        if let pair = self.firingEvents[item.id] {
            self.firingEvents[item.id] = (item: item, sound: pair.sound)
        }
    }
}

extension FileAlarmSound {
    
    static func alarmSounds(withURLs urls:[URL]) -> [AlarmSound] {
        var sounds:[AlarmSound] = []
        for url in urls {
            if let alarm = FileAlarmSound(withURL: url) {
                sounds.append(alarm)
                AlarmSoundController.logger.error("Loaded sound for URL: \(url)")
            } else {
                AlarmSoundController.logger.error("Failed to load sound for URL: \(url)")
            }
        }
        return sounds
    }
    
}


