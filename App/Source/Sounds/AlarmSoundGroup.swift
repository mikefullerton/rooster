//
//  AlarmSoundGroup.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation

class AlarmSoundGroup : AlarmSound, AlarmSoundDelegate {
    weak var delegate: AlarmSoundDelegate?
    
    private(set) var name: String
    private(set) var behavior: AlarmSoundBehavior
    private let sounds:[AlarmSound]
    private var currentSoundIndex = -1
    
    var identifier: String
    
    init(withPreference preference: SoundPreference) {
        self.sounds = AVAlarmSound.alarmSounds(withURLs: preference.soundURLs)
    
        self.name = preference.sounds.map { $0.fileName }.joined(separator: ":")
        self.behavior = AlarmSoundBehavior()
        self.identifier = ""
    }
    
    var currentSound: AlarmSound? {
        if self.currentSoundIndex >= 0 && self.currentSoundIndex < self.sounds.count {
            return self.sounds[self.currentSoundIndex]
        }
        
        return nil
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

    private func playNextSound() {
        self.currentSoundIndex += 1
        
        if self.currentSoundIndex >= self.sounds.count {
            self.currentSoundIndex = 0
        }
        
        if let currentSound = self.currentSound {
            
            self.logger.log("Playing next sound: \(currentSound.name)")
            
            let behavior = AlarmSoundBehavior(playCount: 1,
                                              timeBetweenPlays: self.behavior.timeBetweenPlays,
                                              fadeInTime: 0)
            
            currentSound.delegate = self
            currentSound.play(withBehavior: behavior)
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
        if self.currentSound != nil {
            self.playNextSound()
        }
    }
    
    func play(withBehavior behavior: AlarmSoundBehavior) {
        self.logger.log("Playing sound: \(self.name)")
        self.behavior = behavior
        self.playNextSound()
    }
    
    func stop() {
        if let currentSound = self.currentSound {
            self.logger.log("Stopped sound: \(self.name)")
            currentSound.stop()
            self.currentSoundIndex = -1
        }
    }
    
    
}
