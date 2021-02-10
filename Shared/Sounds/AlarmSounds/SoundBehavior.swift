//
//  AlarmSoundBehavior.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation

struct SoundBehavior {
    static let RepeatEndlessly = Int.max
    
    static let DefaultTimeBetweenPlays:TimeInterval = 0
    
    let playCount: Int
    let timeBetweenPlays: TimeInterval
    let fadeInTime: TimeInterval
    
    init(playCount: Int,
         timeBetweenPlays: TimeInterval,
         fadeInTime: TimeInterval) {
        self.playCount = playCount
        self.timeBetweenPlays = timeBetweenPlays
        self.fadeInTime = fadeInTime
    }
    
    init() {
        self.init(playCount: 0, timeBetweenPlays: 0, fadeInTime: 0)
    }
}
