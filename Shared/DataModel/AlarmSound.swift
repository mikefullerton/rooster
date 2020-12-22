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
    
    init(withName name: String) {
        self.name = name
        self.timer = SimpleTimer()
        self.behavior = AlarmSoundBehavior()
        self.duration = 0
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
    
    func play(withBehavior behavior: AlarmSoundBehavior) {
        
        self.behavior = behavior
        
        self.duration = self.startPlayingSound() + behavior.timeBetweenPlays
        
        if let delegate = self.delegate {
            delegate.soundWillStartPlaying(self, forIdentifier: behavior.identifier)
        }

        self.logger.log("playing sound: \(self.name): for: \(behavior.identifier)")

        weak var weakSelf = self
        self.timer.start(withInterval: self.duration,
                         playCount: behavior.playCount) { (timer) in
            
            if let strongSelf = weakSelf {
                if timer.willFireAgain {
                    strongSelf.duration = strongSelf.startPlayingSound() + strongSelf.behavior.timeBetweenPlays
                } else {
                    strongSelf.stop()
                }
            }
        }
    }
    
    func stopPlayingSound() {
        
    }
    
    func stop() {
        if self.isPlaying {
            
            self.stopPlayingSound()
            
            if let delegate = self.delegate {
                delegate.soundDidStopPlaying(self)
            }

            self.logger.log("stopped sound: \(self.name): for: \(self.behavior.identifier)")
        }
    }
    
}

