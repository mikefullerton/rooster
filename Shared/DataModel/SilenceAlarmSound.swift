//
//  EmptyAlarmSound.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/17/20.
//

import Foundation

class SilenceAlarmSound : AlarmSound {
    
    struct FakeSound {
        var isPlaying: Bool
        var duration: TimeInterval
        var volume: Float
        var startTime: TimeInterval
    }
    
    private var sound: FakeSound
    
    init(withDuration duration: TimeInterval = 0) {
        self.sound = FakeSound(isPlaying: false, duration: duration, volume: 1.0, startTime: 0)
        super.init(withName: "Silence")
    }

    override var isPlaying: Bool {
        return self.sound.isPlaying
    }
    
    override var volume: Float {
        return self.sound.volume
    }
    
    override func set(volume: Float, fadeDuration: TimeInterval) {
        self.sound.volume = volume
    }
    
    override var currentTime: TimeInterval {
        
        if !self.isPlaying {
            return 0
        }
        
        return Date.timeIntervalSinceReferenceDate - self.sound.startTime
    }
    
    override func startPlayingSound() -> TimeInterval {
        self.sound.startTime = Date.timeIntervalSinceReferenceDate
        self.sound.isPlaying = true
        return self.duration + self.behavior.timeBetweenPlays
    }
    
    override func stopPlayingSound() {
        self.sound.startTime = 0
        self.sound.isPlaying = false
    }
}
