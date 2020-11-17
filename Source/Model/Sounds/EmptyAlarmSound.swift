//
//  EmptyAlarmSound.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/17/20.
//

import Foundation

class EmptyAlarmSound : AlarmSound {
    var name: String {
        return ""
    }
    
    var isPlaying: Bool {
        return false
    }
    
    func play() {
    }
    
    func stop() {
    }
    
    var duration: TimeInterval {
        return 0
    }
    
    var numberOfLoops: Int {
        return 0
    }
    
    var volume: Float {
        return 0
    }
    
    func set(volume: Float, fadeDuration: TimeInterval) {
    }
    
    var currentTime: TimeInterval {
        return 0
    }
}
