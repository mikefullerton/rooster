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
    
    static let RepeatEndlessly = Int.max
    
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

protocol AlarmSound : AnyObject {
    var delegate: AlarmSoundDelegate? { get set }
    var name: String { get }
    var duration: TimeInterval { get }
    var behavior: AlarmSoundBehavior { get }
    var isPlaying: Bool { get }
    var currentTime: TimeInterval { get }
    var volume: Float { get }
    func set(volume: Float, fadeDuration: TimeInterval)
    func play(withBehavior behavior: AlarmSoundBehavior)
    func stop()
}

extension AlarmSound {

    static var logger: Logger {
        return Logger(subsystem: "com.apple.rooster", category: "AlarmSound")
    }
    
    var logger: Logger {
        return type(of: self).logger
    }
}

/*

    let name: String
    private let timer: SimpleTimer
    private(set) var behavior: AlarmSoundBehavior
    private(set) var duration: TimeInterval
    
    
    
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
    
    
    
    func stopPlayingSound() {
        
    }
    
  
*/
