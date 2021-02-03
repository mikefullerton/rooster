//
//  SoundFileAlarmSound.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/21/21.
//

import Foundation
import Cocoa

class SoundFileAlarmSound : NSObject, AlarmSound, NSSoundDelegate, Loggable {
    weak var delegate: AlarmSoundDelegate?
    
    var identifier: String
    
    private(set) var behavior: AlarmSoundBehavior
    let soundFile: SoundFile
    
    private var sound: NSSound?
    private let stopTimer: SimpleTimer
    
    private(set) var isPlaying: Bool
    
    init(withSoundFile soundFile: SoundFile) {
        self.soundFile = soundFile
        self.behavior = AlarmSoundBehavior()
        self.stopTimer = SimpleTimer(withName: "AVAlarmSoundStopTimer")
        self.identifier = ""
        self.isPlaying = false
        self.sound = nil
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: PreferencesController.DidChangeEvent, object: nil)
    }
    
    deinit {
        self.stopTimer.stop()
        self.fadeOutAndStop()
    }
    
    var name: String {
        return self.soundFile.name
    }
    
    private func createPlayerIfNeeded() {
        guard self.sound == nil else {
            return
        }
        
        let soundFile = self.soundFile
        if let sound = NSSound(contentsOf: soundFile.url, byReference: true){
            sound.setName(soundFile.name)
            sound.delegate = self
            self.sound = sound
            
        } else {
            self.logger.error("Failed to create sound for soundFile: \(soundFile)")
            return
        }
        
        self.updateVolume()
    }
    
    private func updateVolume() {
        if let sound = self.sound {
            sound.volume = AppDelegate.instance.preferencesController.soundPreferences.volume
        }
    }
    
    @objc func preferencesDidChange(_ sender: Notification) {
        self.updateVolume()
    }

    var volume: Float {
        if let sound = self.sound {
            return sound.volume
        }
        return 0
    }
    
    var duration: TimeInterval {
        if let sound = self.sound {
            return sound.duration
        }
        
        return 0
    }
    
    func set(volume: Float, fadeDuration: TimeInterval) {
        if let sound = self.sound {
            sound.volume = volume
        }
    }
    
    var currentTime: TimeInterval {
        if let sound = self.sound {
            return sound.currentTime
        }
        
        return 0
    }
        
    static func == (lhs: SoundFileAlarmSound, rhs: SoundFileAlarmSound) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func play(withBehavior behavior: AlarmSoundBehavior) {
        self.createPlayerIfNeeded()
        self.isPlaying = true
        self.logger.log("Sound will start playing: \(self.name)")
        if let delegate = self.delegate {
            delegate.soundWillStartPlaying(self)
        }

        DispatchQueue.main.async {
            if let sound = self.sound {
                sound.loops = false
                self.updateVolume()
                sound.play()
            } else {
                self.didStop()
            }
        }
    }
    
    func stop() {
        self.logger.log("Sound will be aborted: \(self.name)")
        self.didStop()
    }
    
    private func fadeOutAndStop() {
        if let sound = self.sound,
            sound.isPlaying {
            sound.stop()
        }
    }
    
    private func didStop() {
        self.logger.log("Sound stopped: \(self.name)")
        self.isPlaying = false
        self.fadeOutAndStop()
        self.stopTimer.stop()
        
        if let delegate = self.delegate {
            delegate.soundDidStopPlaying(self)
        }
    }
    
    private func notifyStopped() {
        if self.behavior.timeBetweenPlays > 0 {
            self.stopTimer.start(withInterval: self.behavior.timeBetweenPlays) { time in
                self.didStop()
            }
        } else {
            self.didStop()
        }
    }
    
    func sound(_ sound: NSSound, didFinishPlaying finished: Bool) {
        if finished {
            self.logger.log("Sound did stop playing: \(self.name)")
            self.notifyStopped()
        }
    }
}

extension SoundFileAlarmSound {
    static func alarmSounds(withSoundFiles soundFiles:[SoundFile]) -> [AlarmSound] {
        var sounds:[AlarmSound] = []
        for soundFile in soundFiles {
            let alarm = SoundFileAlarmSound(withSoundFile: soundFile)
            sounds.append(alarm)
            self.logger.error("Loaded sound for SoundFile: \(soundFile)")
        }
        return sounds
    }
    
}



