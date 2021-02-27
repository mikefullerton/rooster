//
//  SoundFileAlarmSound.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/21/21.
//

import Foundation
import Cocoa

public class SoundPlayer : NSObject, Sound, NSSoundDelegate, Loggable, Identifiable {
    
    public typealias ID = String
    
    public weak var delegate: SoundDelegate?
    
    public var id: String
    
    private(set) public var behavior: SoundBehavior
    public let soundFile: SoundFile
    public let randomizer: PlayListRandomizer
    
    private var sound: NSSound?
    private let stopTimer: SimpleTimer
    
    private(set) public var isPlaying: Bool
    
    public init(withSoundFile soundFile: SoundFile, randomizer: PlayListRandomizer?) {
        self.soundFile = soundFile
        self.randomizer = randomizer == nil ? PlayListRandomizer.never : randomizer!
        self.behavior = SoundBehavior()
        self.stopTimer = SimpleTimer(withName: "SoundPlayer")
        self.id = soundFile.id
        self.isPlaying = false
        self.sound = nil
        super.init()
  
        NotificationCenter.default.addObserver(self, selector: #selector(soundVolumeChanged(_:)), name: GlobalSoundVolume.volumeChangedNotification, object: nil)
    }
    
    deinit {
        self.stopTimer.stop()
        self.fadeOutAndStop()
    }
    
    public var displayName: String {
        return self.soundFile.displayName
    }
    
    private func createPlayerIfNeeded() {
        guard self.sound == nil else {
            return
        }
        
        let soundFile = self.soundFile
        
        if  let path = soundFile.absolutePath,
            let sound = NSSound(contentsOf: path, byReference: true){
            
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
            sound.volume = GlobalSoundVolume.volume
        }
    }
    
    @objc func soundVolumeChanged(_ sender: Notification) {
        self.updateVolume()
    }

    public var volume: Float {
        if let sound = self.sound {
            return sound.volume
        }
        return 0
    }
    
    public var duration: TimeInterval {
        if let sound = self.sound {
            return sound.duration
        }
        
        return 0
    }
    
    public func set(volume: Float, fadeDuration: TimeInterval) {
        if let sound = self.sound {
            sound.volume = volume
        }
    }
    
    public var currentTime: TimeInterval {
        if let sound = self.sound {
            return sound.currentTime
        }
        
        return 0
    }
        
    public static func == (lhs: SoundPlayer, rhs: SoundPlayer) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func play(withBehavior behavior: SoundBehavior) {
        self.createPlayerIfNeeded()
        self.isPlaying = true
        self.logger.log("Sound will start playing: \(self.displayName): url: \(self.soundFile.absolutePath?.path ?? "nil")")
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
    
    public func stop() {
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
    
    public func sound(_ sound: NSSound, didFinishPlaying finished: Bool) {
        if finished {
            self.logger.log("Sound did stop playing: \(self.displayName)")
            self.notifyStopped()
        }
    }
}

