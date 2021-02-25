//
//  SoundFileAlarmSound.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/21/21.
//

import Foundation
import Cocoa

class SoundFileSoundPlayer : NSObject, Sound, NSSoundDelegate, Loggable, Identifiable {
    
    typealias ID = String
    
    weak var delegate: SoundDelegate?
    
    var id: String
    
    private(set) var behavior: SoundBehavior
    let soundFile: SoundFile
    let randomizer: RandomizationDescriptor
    
    private var sound: NSSound?
    private let stopTimer: SimpleTimer
    
    private(set) var isPlaying: Bool
    
    init(withSoundFile soundFile: SoundFile, randomizer: RandomizationDescriptor?) {
        self.soundFile = soundFile
        self.randomizer = randomizer == nil ? RandomizationDescriptor.never : randomizer!
        self.behavior = SoundBehavior()
        self.stopTimer = SimpleTimer(withName: "AVAlarmSoundStopTimer")
        self.id = soundFile.id
        self.isPlaying = false
        self.sound = nil
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: PreferencesController.DidChangeEvent, object: nil)
    }
    
    deinit {
        self.stopTimer.stop()
        self.fadeOutAndStop()
    }
    
    var displayName: String {
        return self.soundFile.displayName
    }
    
    private func createPlayerIfNeeded() {
        guard self.sound == nil else {
            return
        }
        
        let soundFile = self.soundFile
        
        if  let url = soundFile.url,
            let sound = NSSound(contentsOf: url, byReference: true){
            
            sound.setName(soundFile.displayName)
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
        
    static func == (lhs: SoundFileSoundPlayer, rhs: SoundFileSoundPlayer) -> Bool {
        return lhs.id == rhs.id
    }
    
    func play(withBehavior behavior: SoundBehavior) {
        self.createPlayerIfNeeded()
        self.isPlaying = true
        self.logger.log("Sound will start playing: \(self.displayName)")
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
        if self.isPlaying {
            self.logger.log("Sound will be aborted: \(self.displayName)")
            self.didStop()
        }
    }
    
    private func fadeOutAndStop() {
        if let sound = self.sound,
            sound.isPlaying {
            sound.stop()
        }
    }
    
    private func didStop() {
        self.logger.log("Sound stopped: \(self.displayName)")
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
            self.logger.log("Sound did stop playing: \(self.displayName)")
            self.notifyStopped()
        }
    }
}

