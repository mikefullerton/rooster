//
//  SoundFileAlarmSound.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/21/21.
//

import Cocoa
import Foundation

public class SoundPlayer: SoundPlayerProtocol, SoundDelegate, Loggable, Identifiable, CustomStringConvertible {
    public typealias ID = String

    public weak var delegate: SoundDelegate?

    public var id: String

    public private(set) var behavior: SoundBehavior
    public let soundFile: SoundFile
    public let randomizer: SoundPlayerRandomizer
    private let stopTimer: SimpleTimer

    public private(set) var isPlaying: Bool

    public init(withSoundFile soundFile: SoundFile, randomizer: SoundPlayerRandomizer?) {
        self.soundFile = soundFile
        self.randomizer = randomizer == nil ? SoundPlayerRandomizer.default : randomizer!
        self.behavior = SoundBehavior()
        self.stopTimer = SimpleTimer(withName: "SoundPlayer")
        self.id = soundFile.id
        self.isPlaying = false

        self.soundFile.soundPlayer.delegate = self

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(soundVolumeChanged(_:)),
                                               name: GlobalSoundVolume.volumeChangedNotification,
                                               object: nil)
    }

    deinit {
        self.stopTimer.stop()
        self.fadeOutAndStop()
    }

    public var description: String {
        """
        \(type(of: self)): \
        id: \(self.id), \
        soundFile: \(self.soundFile.description), \
        randomizer: \(self.randomizer.description), \
        behavior: \(self.behavior.description)
        """
    }

    public var displayName: String {
        self.soundFile.displayNameWithParentsExcludingRoot
    }

    private func updateVolume() {
        self.set(volume: GlobalSoundVolume.volume, fadeDuration: 0)
    }

    @objc func soundVolumeChanged(_ sender: Notification) {
        self.updateVolume()
    }

    public var volume: Float {
        self.soundFile.soundPlayer.volume
    }

    public var duration: TimeInterval {
        self.soundFile.soundPlayer.duration
    }

    public func set(volume: Float, fadeDuration: TimeInterval) {
        self.soundFile.soundPlayer.set(volume: volume, fadeDuration: fadeDuration)
    }

    public var currentTime: TimeInterval {
        self.soundFile.soundPlayer.currentTime
    }

    public static func == (lhs: SoundPlayer, rhs: SoundPlayer) -> Bool {
        lhs.id == rhs.id
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

        if self.delegate == nil {
            self.logger.log("delegate is nil")
        }

        self.delegate?.soundDidStopPlaying(self)
    }

    private func notifyStopped() {
        if self.behavior.timeBetweenPlays > 0 {
            self.stopTimer.start(withInterval: self.behavior.timeBetweenPlays) { _ in
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
