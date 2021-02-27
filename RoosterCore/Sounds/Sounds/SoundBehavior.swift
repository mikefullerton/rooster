//
//  AlarmSoundBehavior.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation

public struct SoundBehavior {
    public static let RepeatEndlessly = Int.max
    
    public static let DefaultTimeBetweenPlays:TimeInterval = 0
    
    public let playCount: Int
    public let timeBetweenPlays: TimeInterval
    public let fadeInTime: TimeInterval
    
    public init(playCount: Int,
         timeBetweenPlays: TimeInterval,
         fadeInTime: TimeInterval) {
        self.playCount = playCount
        self.timeBetweenPlays = timeBetweenPlays
        self.fadeInTime = fadeInTime
    }
    
    public init() {
        self.init(playCount: 0, timeBetweenPlays: 0, fadeInTime: 0)
    }
}
