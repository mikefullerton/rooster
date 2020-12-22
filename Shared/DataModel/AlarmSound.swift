//
//  AlarmSound.swift
//  Rooster
//
//  Created by Mike Fullerton on 11/13/20.
//

import Foundation
import OSLog

protocol AlarmSoundDelegate : AnyObject {
    func soundWillStartPlaying(_ sound: AlarmSound, forIdentifier identifier: String)
    func soundDidStopPlaying(_ sound: AlarmSound)
}

struct AlarmSoundBehavior {
    
    static let RepeatEndlessly = 0
    
    let identifier: String
    let playCount: Int
    let timeBetweenPlays: TimeInterval
    let fadeInTime: TimeInterval
    
    init(withIdentifier identifier: String,
         playCount: Int,
         timeBetweenPlays: TimeInterval,
         fadeInTime: TimeInterval) {
        self.identifier = identifier
        self.playCount = playCount
        self.timeBetweenPlays = timeBetweenPlays
        self.fadeInTime = fadeInTime
    }
    
    init() {
        self.init(withIdentifier: "", playCount: 0, timeBetweenPlays: 0, fadeInTime: 0)
    }
}

protocol AlarmSoundSubclass {
    
}

class AlarmSound {
    
    weak var delegate: AlarmSoundDelegate?
    
    static let logger = Logger(subsystem: "com.apple.rooster", category: "AlarmSound")
    
    var logger: Logger {
        return AlarmSound.logger
    }
    
    let name: String
    private let timer: SimpleTimer
    private(set) var behavior: AlarmSoundBehavior
    private(set) var duration: TimeInterval
    
    private var playCount:Int
    
    init(withName name: String) {
        self.name = name
        self.timer = SimpleTimer()
        self.behavior = AlarmSoundBehavior()
        self.duration = 0
        self.playCount = 0
    }
    
    var isPlaying: Bool {
        return false
    }
    
    var currentTime: TimeInterval {
        return  0
    }
    
    var volume: Float {
        return 0
    }

    func set(volume: Float, fadeDuration: TimeInterval) {
    }
    
    func startPlayingSound() -> TimeInterval {
        return 0
    }
    
    private func startTimer() {
        weak var weakSelf = self
        self.timer.start(withInterval: self.duration) { (timer) in
        
            if let strongSelf = weakSelf {
                strongSelf.playCount += 1
                
                if  strongSelf.behavior.playCount == AlarmSoundBehavior.RepeatEndlessly ||
                    strongSelf.playCount < strongSelf.behavior.playCount {
                    
                    strongSelf.startTimer()
                } else {
                    strongSelf.stop()
                }
                
            }
        }
    }
    
    func play(withBehavior behavior: AlarmSoundBehavior) {
        
        self.behavior = behavior
        self.playCount = 0
        
        self.duration = self.startPlayingSound()
        
        if let delegate = self.delegate {
            delegate.soundWillStartPlaying(self, forIdentifier: behavior.identifier)
        }

        self.logger.log("playing sound: \(self.name): for: \(behavior.identifier)")

        self.startTimer()
    }
    
    func stopPlayingSound() {
        
    }
    
    func stop() {
        if self.isPlaying {
            self.timer.stop()
            if let delegate = self.delegate {
                delegate.soundDidStopPlaying(self)
            }

            self.logger.log("stopped sound: \(self.name): for: \(self.behavior.identifier)")

            self.stopPlayingSound()
        }
    }
    
}

