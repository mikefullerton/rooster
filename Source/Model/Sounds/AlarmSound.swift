//
//  AlarmSound.swift
//  Rooster
//
//  Created by Mike Fullerton on 11/13/20.
//

import Foundation

protocol AlarmSoundDelegate : AnyObject {
    func soundWillStartPlaying(_ sound: AlarmSound)
    func soundDidStopPlaying(_ sound: AlarmSound)
}

protocol AlarmSound : AnyObject {
    
    var name: String { get }
    
    var isPlaying: Bool { get }
    
    var duration: TimeInterval { get }
    
    var currentTime: TimeInterval { get }
    
    var numberOfLoops: Int { get }
    
    var volume: Float { get }

    func set(volume: Float, fadeDuration: TimeInterval)
    
    func play()
    
    func stop()
}


