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

protocol AlarmSound : AnyObject, Loggable {
    var delegate: AlarmSoundDelegate? { get set }
    
    var id: String { get }
    var name: String { get }
    var duration: TimeInterval { get }
    var behavior: AlarmSoundBehavior { get }
    var isPlaying: Bool { get }
    var currentTime: TimeInterval { get }
    var volume: Float { get }
    func set(volume: Float, fadeDuration: TimeInterval)
    func play(withBehavior behavior: AlarmSoundBehavior)
    func stop()
    
    var displayName: String { get }
}
