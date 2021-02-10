//
//  AlarmSoundGroup.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation

class SoundPlayList : Sound, SoundDelegate, Identifiable {
    typealias ID = String
    
    let id: String
    
    weak var delegate: SoundDelegate?
    
    let displayName: String

    private(set) var sounds:[Sound]

    var playListIterator: PlayListIteratorProtocol
    
    private(set) var behavior: SoundBehavior
    private(set) var currentSound: Sound?
    private var playCount: Int = 0
    
    init(withPlayListIterator playListIterator: PlayListIteratorProtocol, displayName: String) {

        self.playListIterator = playListIterator
        self.sounds = playListIterator.sounds.map {
            return SoundFileAlarmSound(withSoundFile: $0)
        }
        self.displayName = displayName
        self.behavior = SoundBehavior()
        self.id = String.guid
    }

    var isPlaying: Bool {
        if let currentSound = self.currentSound {
            return currentSound.isPlaying
        }
        
        return false
    }
    
    var isEmpty: Bool {
        return self.sounds.count == 0
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
    
    var currentSoundDisplayName: String {
        
        if let currentSound = self.currentSound {
            return currentSound.displayName
        }
        
        if self.sounds.count > 0 {
            return self.sounds[0].displayName
        }
        
        return ""
    }
    
    private func didStopCurrentSound() {
        if let currentSound = self.currentSound {
            currentSound.delegate = nil
            self.currentSound = nil
            
            self.delegate?.soundDidUpdate(self)
        }
    }
    
    private func advance() -> Bool {
        self.didStopCurrentSound()
        
        if let nextSound = self.playListIterator.step(),
           let alarmSound = self.sounds.first(where: { $0.id == nextSound.id }) {
            
            self.currentSound = alarmSound
            
            return true
        }
        
        return false
    }
    
    private func playNextSound() {

        self.didStopCurrentSound()
        
        if let nextSound = self.playListIterator.step(),
           let alarmSound = self.sounds.first(where: { $0.id == nextSound.id }) {
            self.currentSound = alarmSound
        } else {
            self.playCount += 1
            if self.behavior.playCount > self.playCount {
                if let nextSound = self.playListIterator.step() {
                    self.sounds = self.playListIterator.sounds.map {
                        return SoundFileAlarmSound(withSoundFile: $0)
                    }
                    if let alarmSound = self.sounds.first(where: { $0.id == nextSound.id }) {
                        self.currentSound = alarmSound
                    }
                }
            }
        }
        
        if let currentSound = self.currentSound {
            self.delegate?.soundDidUpdate(self)

            self.logger.log("Playing next sound: '\(currentSound.displayName)'")
            
            let behavior = SoundBehavior(playCount: 1,
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
    
    func soundWillStartPlaying(_ sound: Sound) {
    
    }
    
    func soundDidStartPlaying(_ sound: Sound) {
        
    }
    
    func soundDidUpdate(_ sound: Sound) {
        self.delegate?.soundDidUpdate(self)
    }

    func soundDidStopPlaying(_ sound: Sound) {
        self.logger.log("Sound did stop: \(sound.displayName)")
        self.playNextSound()
    }
    
    func play(withBehavior behavior: SoundBehavior) {
        if !self.isPlaying {
            self.logger.log("Playing sounds: \(self.displayName): \(self.currentSoundDisplayName)")
            self.behavior = behavior
            
            self.delegate?.soundWillStartPlaying(self)
            self.playCount = 0
            self.playNextSound()
            
            self.delegate?.soundDidStartPlaying(self)
        }
    }
    
    private func didStop() {
        if let sound = self.currentSound {
            sound.delegate = nil
            sound.stop()
            self.currentSound = nil
        }
        
        self.delegate?.soundDidStopPlaying(self)
        self.logger.log("All sounds stopped playing: \(self.displayName): \(self.currentSoundDisplayName)")
    }
    
    func stop() {
        if self.isPlaying {
            self.didStop()
        }
    }
    
    
}
