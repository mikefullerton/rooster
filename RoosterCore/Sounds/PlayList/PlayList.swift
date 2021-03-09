//
//  AlarmSoundGroup.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation

public class PlayList: SoundPlayerProtocol, SoundDelegate, Identifiable, CustomStringConvertible {
    public typealias ID = String

    public let id: String

    public weak var delegate: SoundDelegate?

    public let displayName: String

    public var playListIterator: PlayListIteratorProtocol

    public private(set) var behavior: SoundBehavior

    public var description: String {
        """
        \(type(of: self)): \
        id: \(self.id), \
        displayName: \(self.displayName), \
        playListIterator: \(self.playListIterator.description)
        """
    }

    public private(set) var currentSoundPlayer: SoundPlayer? {
        willSet {
            self.currentSoundPlayer?.delegate = nil
        }
        didSet {
            self.currentSoundPlayer?.delegate = self
        }
    }

    private var playCount: Int = 0

    public convenience init() {
        self.init(withPlayListIterator: PlayListIterator(), displayName: "")
    }

    public convenience init(withSoundSet soundSet: SoundSet) {
        self.init(withPlayListIterator: PlayListIterator(withSoundSet: soundSet), displayName: soundSet.displayName)
    }

    public init(withPlayListIterator playListIterator: PlayListIteratorProtocol, displayName: String) {
        self.playListIterator = playListIterator
        self.displayName = displayName
        self.behavior = SoundBehavior()
        self.id = String.guid

        self.currentSoundPlayer = nil

        self.playListIterator.start()
        self.currentSoundPlayer = self.playListIterator.current
    }

    public var isRandom: Bool {
        self.playListIterator.isRandom
    }

    public var soundPlayers: [SoundPlayer] {
        self.playListIterator.soundPlayers
    }

    public private(set) var isPlaying = false

    public var isEmpty: Bool {
        self.soundPlayers.isEmpty
    }

    public var volume: Float {
        if let currentSoundPlayer = self.currentSoundPlayer {
            return currentSoundPlayer.volume
        }

        return 0
    }

    public func set(volume: Float, fadeDuration: TimeInterval) {
        self.soundPlayers.forEach { $0.set(volume: volume, fadeDuration: fadeDuration) }
    }

    public var currentTime: TimeInterval {
        // NOTE: this isn't correct overall
        if let currentSoundPlayer = self.currentSoundPlayer {
            return currentSoundPlayer.currentTime
        }
        return 0
    }

    public var currentSoundDisplayName: String {
        if let currentSoundPlayer = self.currentSoundPlayer {
            return currentSoundPlayer.displayName
        }

//        if self.soundsPlayers.count > 0 {
//            return self.soundsPlayers[0].displayName
//        }

        return ""
    }

    private var nextSoundFromPlaylist: SoundPlayer? {
        self.playListIterator.next()

        if let nextSound = self.playListIterator.current {
            return nextSound
        } else {
            self.playCount += 1
            if self.behavior.playCount > self.playCount {
                self.playListIterator.start()
                if let nextSound = self.playListIterator.current {
                    return nextSound
                }
            }
        }

        return nil
    }

    private func playNextSound(_ soundPlayer: SoundPlayer) {
        self.logger.log("Playing next sound: '\(soundPlayer.displayName)'")

        let behavior = SoundBehavior(playCount: 1,
                                     timeBetweenPlays: self.behavior.timeBetweenPlays,
                                     fadeInTime: 0)

        soundPlayer.delegate = self
        soundPlayer.play(withBehavior: behavior)
    }

    public var duration: TimeInterval {
        var duration: TimeInterval = 0
        self.soundPlayers.forEach { duration += $0.duration + self.behavior.timeBetweenPlays }
        return duration
    }

    public func soundWillStartPlaying(_ sound: SoundPlayerProtocol) {
    }

    public func soundDidStartPlaying(_ sound: SoundPlayerProtocol) {
    }

    public func soundDidUpdate(_ sound: SoundPlayerProtocol) {
        self.delegate?.soundDidUpdate(self)
    }

    public func soundDidStopPlaying(_ sound: SoundPlayerProtocol) {
        self.logger.log("Sound did stop: \(sound.displayName)")
        if let nextSound = self.nextSoundFromPlaylist {
            self.currentSoundPlayer = nextSound
            self.playNextSound(nextSound)
            self.delegate?.soundDidUpdate(self)
        } else {
            self.didStop()
        }
    }

    public func play(withBehavior behavior: SoundBehavior) {
        if !self.isPlaying {
            self.isPlaying = true
            self.behavior = behavior
            self.playCount = 0
            self.playListIterator.start()

            if let current = self.playListIterator.current {
                self.delegate?.soundWillStartPlaying(self)
                self.currentSoundPlayer = current

                self.logger.log("Playing sounds: \(self.displayName): \(self.currentSoundDisplayName)")

                self.playNextSound(current)
                self.delegate?.soundDidStartPlaying(self)
            } else {
                self.didStop()
            }
        }
    }

    private func didStop() {
        if self.isPlaying {
            self.isPlaying = false
            self.delegate?.soundDidStopPlaying(self)
            self.logger.log("All sounds stopped playing: \(self.displayName): \(self.currentSoundDisplayName)")
        }
    }

    public func stop() {
        if let currentSoundPlayer = self.currentSoundPlayer {
            if currentSoundPlayer.isPlaying {
                currentSoundPlayer.delegate = nil
                currentSoundPlayer.stop()
                currentSoundPlayer.delegate = self
            }
        }
        self.didStop()
    }
}
