//
//  AlarmSoundGroup.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation

protocol SoundSetAlarmSoundDelegate:AlarmSoundDelegate {
    func alarmSound(_ soundSetAlarmSound: SoundSetAlarmSound, willStartPlayingAlarmSound alarmSound:AlarmSound )
    func alarmSound(_ soundSetAlarmSound: SoundSetAlarmSound, didStopPlayingAlarmSound alarmSound:AlarmSound )
}

class SoundSetAlarmSound : AlarmSound, AlarmSoundDelegate, Identifiable {
    typealias ID = String
    
    let id: String
    
    weak var delegate: AlarmSoundDelegate?
    
    let name: String
    let soundSetIterator: SoundSetIterator
    
    private(set) var behavior: AlarmSoundBehavior
    private(set) var currentSound: AlarmSound?
    private let sounds:[AlarmSound]
    private var playCount: Int = 0
    
    init(withSoundSetIterator soundSetIterator: SoundSetIterator) {

        self.sounds = soundSetIterator.sounds.map { return SoundFileAlarmSound(withSoundFile: $0) }
        self.soundSetIterator = soundSetIterator
        
        self.name = self.soundSetIterator.sounds.map { $0.name }.joined(separator: ":")
        self.behavior = AlarmSoundBehavior()
        self.id = self.soundSetIterator.sounds.map { $0.id }.joined(separator: ":")
    }

    var isPlaying: Bool {
        if let currentSound = self.currentSound {
            return currentSound.isPlaying
        }
        
        return false
    }
    
    var volume: Float {
        if let currentSound = self.currentSound {
            return currentSound.volume
        }
        
        return 0
    }
    
    func set(volume: Float, fadeDuration: TimeInterval) {
        self.sounds.forEach { $0.set(volume: volume, fadeDuration: fadeDuration) }
    }
    
    var currentTime: TimeInterval {
        // TODO this isn't correct overall
        if let currentSound = self.currentSound {
            return currentSound.currentTime
        }
        return 0
    }
    
    var displayName: String {
        return self.soundSetIterator.displayName
    }
    
    private func didStopCurrentSound() {
        if let currentSound = self.currentSound {
            currentSound.delegate = nil
            self.currentSound = nil
            if let delegate = self.delegate as? SoundSetAlarmSoundDelegate {
                delegate.alarmSound(self, willStartPlayingAlarmSound: currentSound)
            }
        }
    }
    
    private func playNextSound() {
        
        self.didStopCurrentSound()
        
        if let nextSound = self.soundSetIterator.advanceForward(),
           let sound = self.sounds.first(where: { $0.id == nextSound.id }) {
            
            self.currentSound = sound
        }
        
        if let currentSound = self.currentSound {
            
            if let delegate = self.delegate as? SoundSetAlarmSoundDelegate {
                delegate.alarmSound(self, willStartPlayingAlarmSound:currentSound)
            }

            self.logger.log("Playing next sound: \(currentSound.name)")
            
            let behavior = AlarmSoundBehavior(playCount: 1,
                                              timeBetweenPlays: self.behavior.timeBetweenPlays,
                                              fadeInTime: 0)
            
            currentSound.delegate = self
            currentSound.play(withBehavior: behavior)
        } else {
            self.didStop()
        }
    }
    
    var duration: TimeInterval {
        var duration: TimeInterval = 0
        self.sounds.forEach { duration += $0.duration + self.behavior.timeBetweenPlays }
        return duration
    }
    
    func soundWillStartPlaying(_ sound: AlarmSound) {
    }
    
    func soundDidStopPlaying(_ sound: AlarmSound) {
        self.logger.log("Sound did stop: \(sound.name)")
        self.didStopCurrentSound()

        if self.soundSetIterator.hasFinished {
            self.playCount += 1
            if self.behavior.playCount > self.playCount {
                self.playNextSound()
            } else {
                self.didStop()
            }

            self.didStop()
        } else {
            self.playNextSound()
        }
    }
    
    func play(withBehavior behavior: AlarmSoundBehavior) {
        if !self.isPlaying {
            self.logger.log("Playing sounds: \(self.name)")
            self.behavior = behavior
            
            self.delegate?.soundWillStartPlaying(self)
            self.playCount = 0
            self.playNextSound()
        }
    }
    
    private func didStop() {
        if let sound = self.currentSound {
            sound.delegate = nil
            sound.stop()
            self.currentSound = nil
        
            if let delegate = self.delegate as? SoundSetAlarmSoundDelegate {
                delegate.alarmSound(self, didStopPlayingAlarmSound: sound)
            }
        }
        
        self.logger.log("All sounds stopped playing: \(self.name)")
        
        self.delegate?.soundDidStopPlaying(self)
    }
    
    func stop() {
        if self.isPlaying {
            self.didStop()
        }
    }
    
    
}
