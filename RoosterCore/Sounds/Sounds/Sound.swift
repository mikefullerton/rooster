//
//  AlarmSound.swift
//  Rooster
//
//  Created by Mike Fullerton on 11/13/20.
//

import Foundation

public protocol SoundDelegate : AnyObject {
    func soundWillStartPlaying(_ sound: Sound)
    func soundDidStartPlaying(_ sound: Sound)
    func soundDidStopPlaying(_ sound: Sound)
    func soundDidUpdate(_ sound: Sound)
}

public protocol Sound: AnyObject, Loggable {
    var delegate: SoundDelegate? { get set }
    
    var id: String { get }
    var displayName: String { get }
    var duration: TimeInterval { get }
    var behavior: SoundBehavior { get }
    var isPlaying: Bool { get }
    var currentTime: TimeInterval { get }
    var volume: Float { get }
    func set(volume: Float, fadeDuration: TimeInterval)
    func play(withBehavior behavior: SoundBehavior)
    func stop()
}

