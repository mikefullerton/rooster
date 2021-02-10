//
//  EmptyAlarmSound.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/17/20.
//

import Foundation

class SilenceAlarmSound : Sound, Identifiable {
    struct FakeSound {
        var isPlaying: Bool
        var duration: TimeInterval
        var volume: Float
        var startTime: TimeInterval
    }
    
    typealias ID = String
    
    weak var delegate: SoundDelegate?

    private var sound: FakeSound
    let name: String
    private let timer: SimpleTimer
    private(set) var behavior: SoundBehavior
    private var playCount:Int
    private(set) var duration: TimeInterval
    var id: String
    
    init(withDuration duration: TimeInterval = 0) {
        self.duration = duration
        self.sound = FakeSound(isPlaying: false, duration: duration, volume: 1.0, startTime: 0)
        self.name = "Silence"
        self.timer = SimpleTimer(withName: "SilenceSoundTimer")
        self.behavior = SoundBehavior()
        self.playCount = 0
        self.id = ""
    }

    var isPlaying: Bool {
        return self.sound.isPlaying
    }
    
    var volume: Float {
        return self.sound.volume
    }
    
    var displayName: String {
        return "Silence"
    }
    
    func set(volume: Float, fadeDuration: TimeInterval) {
        self.sound.volume = volume
    }
    
    var currentTime: TimeInterval {
        
        if !self.isPlaying {
            return 0
        }
        
        return Date.timeIntervalSinceReferenceDate - self.sound.startTime
    }
    
    private func startTimer(withDuration duration: TimeInterval) {
        self.timer.start(withInterval: duration) { [weak self] (timer) in
        
            if let strongSelf = self {
                strongSelf.playCount += 1
                
                if  strongSelf.behavior.playCount == SoundBehavior.RepeatEndlessly ||
                    strongSelf.playCount < strongSelf.behavior.playCount {
                    
                    strongSelf.startTimer(withDuration: duration)
                } else {
                    strongSelf.stop()
                }
                
            }
        }
    }
    
    func play(withBehavior behavior: SoundBehavior) {
        
        self.behavior = behavior
        self.playCount = 0

        self.sound.startTime = Date.timeIntervalSinceReferenceDate
        self.sound.isPlaying = true

        if let delegate = self.delegate {
            delegate.soundWillStartPlaying(self)
        }

        self.logger.log("playing sound: \(self.name): for: \(self.id)")

        self.startTimer(withDuration: self.duration + self.behavior.timeBetweenPlays)
    }
    
    func stop() {
        if self.isPlaying {
            self.timer.stop()
            if let delegate = self.delegate {
                delegate.soundDidStopPlaying(self)
            }

            self.logger.log("stopped sound: \(self.name): for: \(self.id)")

            self.sound.startTime = 0
            self.sound.isPlaying = false
        }
    }
}
