//
//  SoundFileAlarmSound.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/21/21.
//

import Foundation
import Cocoa

public class SoundPlayer : NSObject, SoundPlayerProtocol, SoundDelegate, Loggable, Identifiable {
    public typealias ID = String
    
    public weak var delegate: SoundDelegate?
    
    public var id: String
    
    private(set) public var behavior: SoundBehavior
    public let soundFile: SoundFile
    public let randomizer: SoundPlayerRandomizer
    private let stopTimer: SimpleTimer
    
    private(set) public var isPlaying: Bool
    
    public init(withSoundFile soundFile: SoundFile, randomizer: SoundPlayerRandomizer?) {
        self.soundFile = soundFile
        self.randomizer = randomizer == nil ? SoundPlayerRandomizer.default : randomizer!
        self.behavior = SoundBehavior()
        self.stopTimer = SimpleTimer(withName: "SoundPlayer")
        self.id = soundFile.id
        self.isPlaying = false
        super.init()
        
        self.soundFile.soundPlayer.delegate = self
  
        NotificationCenter.default.addObserver(self, selector: #selector(soundVolumeChanged(_:)), name: GlobalSoundVolume.volumeChangedNotification, object: nil)
    }
    
    deinit {
        self.stopTimer.stop()
        self.fadeOutAndStop()
    }
    
    public var displayName: String {
        return self.soundFile.displayNameWithParentsExcludingRoot
    }
    
    private func updateVolume() {
        self.set(volume: GlobalSoundVolume.volume, fadeDuration: 0)
    }
    
    @objc func soundVolumeChanged(_ sender: Notification) {
        self.updateVolume()
    }

    public var volume: Float {
        return self.soundFile.soundPlayer.volume
    }
    
    public var duration: TimeInterval {
        return self.soundFile.soundPlayer.duration
    }
    
    public func set(volume: Float, fadeDuration: TimeInterval) {
        self.soundFile.soundPlayer.set(volume: volume, fadeDuration: fadeDuration)
    }
    
    public var currentTime: TimeInterval {
        return self.soundFile.soundPlayer.currentTime
    }
        
    public static func == (lhs: SoundPlayer, rhs: SoundPlayer) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func play(withBehavior behavior: SoundBehavior) {
        self.isPlaying = true
        self.logger.log("Sound will start playing: \(self.displayName): url: \(self.soundFile.absolutePath?.path ?? "nil")")
        if let delegate = self.delegate {
            delegate.soundWillStartPlaying(self)
        }

        DispatchQueue.main.async {
            self.updateVolume()
            self.soundFile.soundPlayer.play(withBehavior: behavior)
        }
    }
    
    public func stop() {
        self.didStop()
    }
    
    private func fadeOutAndStop() {
        if self.soundFile.soundPlayer.isPlaying {
            self.soundFile.soundPlayer.stop()
        }
    }
    
    private func didStop() {
        self.logger.log("Sound stopped: \(self.displayName)")
        self.isPlaying = false
        self.fadeOutAndStop()
        self.stopTimer.stop()
        
        self.delegate?.soundDidStopPlaying(self)
    }
    
    private func notifyStopped() {
        if self.behavior.timeBetweenPlays > 0 {
            self.stopTimer.start(withInterval: self.behavior.timeBetweenPlays) { time in
                self.didStop()
            }
        } else {
            self.didStop()
        }
    }
    
    public func sound(_ sound: NSSound, didFinishPlaying finished: Bool) {
        if finished {
            self.logger.log("Sound did stop playing: \(self.displayName)")
            self.notifyStopped()
        }
    }

    public func soundWillStartPlaying(_ sound: SoundPlayerProtocol) {
    }
    
    public func soundDidStartPlaying(_ sound: SoundPlayerProtocol) {
    }
    
    public func soundDidStopPlaying(_ sound: SoundPlayerProtocol) {
        self.logger.log("Sound did stop playing: \(self.displayName)")
        self.notifyStopped()
    }
    
    public func soundDidUpdate(_ sound: SoundPlayerProtocol) {
        self.delegate?.soundDidUpdate(self)
    }
}

