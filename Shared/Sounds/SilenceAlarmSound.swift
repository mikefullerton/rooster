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
    
    weak var delegate: AlarmSoundDelegate?

    private var sound: FakeSound
    let name: String
    private let timer: SimpleTimer
    private(set) var behavior: AlarmSoundBehavior
    private var playCount:Int
    private(set) var duration: TimeInterval
    var identifier: String
    
    init(withDuration duration: TimeInterval = 0) {
        self.duration = duration
        self.sound = FakeSound(isPlaying: false, duration: duration, volume: 1.0, startTime: 0)
        self.name = "Silence"
        self.timer = SimpleTimer()
        self.behavior = AlarmSoundBehavior()
        self.playCount = 0
        self.identifier = ""
    }

    var isPlaying: Bool {
        return self.sound.isPlaying
    }
    
    var volume: Float {
        return self.sound.volume
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
        weak var weakSelf = self
        self.timer.start(withInterval: duration) { (timer) in
        
            if let strongSelf = weakSelf {
                strongSelf.playCount += 1
                
                if  strongSelf.behavior.playCount == AlarmSoundBehavior.RepeatEndlessly ||
                    strongSelf.playCount < strongSelf.behavior.playCount {
                    
                    strongSelf.startTimer(withDuration: duration)
                } else {
                    strongSelf.stop()
                }
                
            }
        }
    }
    
    func play(withBehavior behavior: AlarmSoundBehavior) {
        
        self.behavior = behavior
        self.playCount = 0

        self.sound.startTime = Date.timeIntervalSinceReferenceDate
        self.sound.isPlaying = true

        if let delegate = self.delegate {
            delegate.soundWillStartPlaying(self)
        }

        self.logger.log("playing sound: \(self.name): for: \(self.identifier)")

        self.startTimer(withDuration: self.duration + self.behavior.timeBetweenPlays)
    }
    
    func stop() {
        if self.isPlaying {
            self.timer.stop()
            if let delegate = self.delegate {
                delegate.soundDidStopPlaying(self)
            }

            self.logger.log("stopped sound: \(self.name): for: \(self.identifier)")

            self.sound.startTime = 0
            self.sound.isPlaying = false
        }
    }
}
