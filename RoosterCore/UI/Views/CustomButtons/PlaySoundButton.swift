//
//  PlaySoundButton.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public protocol PlaySoundButtonDelegate: AnyObject {
    func playSoundButton(_ playSoundButton: PlaySoundButton, willStartPlayingSound sound: SoundPlayerProtocol)
    func playSoundButton(_ playSoundButton: PlaySoundButton, didStartPlayingSound sound: SoundPlayerProtocol)
    func playSoundButton(_ playSoundButton: PlaySoundButton, didStopPlayingSound sound: SoundPlayerProtocol)
    func playSoundButton(_ playSoundButton: PlaySoundButton, soundDidUpdate sound: SoundPlayerProtocol)
}

public protocol PlaySoundButtonSoundProvider: AnyObject {
    func playSoundButtonProvideSound(_ playSoundButton: PlaySoundButton) -> SoundPlayerProtocol?
    func playSoundButtonProvideSoundBehavior(_ playSoundButton: PlaySoundButton) -> SoundBehavior
}

public  class PlaySoundButton: FancyButton, SoundDelegate {
    public static let defaultSoundBehavior = SoundBehavior(playCount: 1, timeBetweenPlays: 0, fadeInTime: 0)

    public weak var delegate: PlaySoundButtonDelegate?
    public weak var soundProvider: PlaySoundButtonSoundProvider?

    private let timer = SimpleTimer(withName: "PlayButtonAnimationTimer")

    public init() {
        super.init(frame: CGRect.zero)

        let names = [
            "speaker",
            "speaker.wave.1",
            "speaker.wave.2",
            "speaker.wave.3",
            "speaker.wave.3"
        ]

        var views: [SDKView] = []

        names.forEach {
            if let view = self.imageView(withName: $0) {
                views.append(view)
            }
        }

        self.animateableContent.contentViews = views

        self.setTarget(self, action: #selector(playSound(_:)))
        self.toolTip = "Play Sound"
    }

    deinit {
        self.timer.stop()

        if let sound = self.playingSound {
            sound.stop()
        }
    }

    @available(*, unavailable)
    public  required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var alarmBehavior: SoundBehavior {
        if let behavior = self.soundProvider?.playSoundButtonProvideSoundBehavior(self) {
            return behavior
        }
        return Self.defaultSoundBehavior
    }

    private var playingSound: SoundPlayerProtocol?

    private func resetContentViewsIfNeeded() {
        if self.playingSound == nil || !self.playingSound!.isPlaying {
            self.animateableContent.viewIndex = 0
        }
    }

    public var isPlaying: Bool {
        self.playingSound?.isPlaying ?? false
    }

    public func startPlaying() {
        if self.isPlaying {
            return
        }

        if let sound = self.soundProvider?.playSoundButtonProvideSound(self) {
            self.playingSound = sound
            sound.delegate = self

            self.delegate?.playSoundButton(self, willStartPlayingSound: sound)
            sound.play(withBehavior: self.alarmBehavior)

            self.startButtonAnimation()
        } else {
            self.didStop()
        }
    }

    private func didStop() {
        self.logger.log("Sound did stop")
        if let sound = self.playingSound {
            if sound.isPlaying {
                sound.delegate = nil
                sound.stop()
            }
            self.playingSound = nil
            self.delegate?.playSoundButton(self, didStopPlayingSound: sound)
        }

        self.stopButtonAnimation()
    }

    public func stopPlaying() {
        if !self.isPlaying {
            return
        }

        self.didStop()
    }

    public func togglePlayingState() {
        if self.isPlaying {
            self.stopPlaying()
        } else {
            self.startPlaying()
        }
    }

    @objc func playSound(_ sender: SDKButton) {
        self.togglePlayingState()
    }

    private func imageView(withName name: String) -> SDKImageView? {
        guard let image = NSImage.image(withSystemSymbolName: name,
                                        accessibilityDescription: "Play Sound",
                                        symbolConfiguration: NSImage.SymbolConfiguration(pointSize: 22, weight: .regular))?
                                            .tint(color: Theme(for: self).secondaryLabelColor) else {
            return nil
        }

        return HighlightableImageView(image: image)
    }

    private func startButtonAnimation() {
        self.resetContentViewsIfNeeded()

        self.timer.start(withInterval: 0.3, fireCount: SimpleTimer.RepeatEndlessly) { [weak self] _ in
            self?.animateableContent.setNextAnimatableView()
        }
    }

    private func stopButtonAnimation() {
        self.timer.stop()
        self.resetContentViewsIfNeeded()
    }

    public func soundWillStartPlaying(_ sound: SoundPlayerProtocol) {
    }

    public func soundDidStartPlaying(_ sound: SoundPlayerProtocol) {
        self.logger.log("Notified Sound did update")
        self.delegate?.playSoundButton(self, didStartPlayingSound: sound)
    }

    public func soundDidStopPlaying(_ alarmSound: SoundPlayerProtocol) {
        self.logger.log("Notified Sound did stop")
        self.didStop()
    }

    public func soundDidUpdate(_ sound: SoundPlayerProtocol) {
        self.logger.log("Notified Sound did update")
        self.delegate?.playSoundButton(self, soundDidUpdate: sound)
    }
}

// class AlarmSoundPlaySoundButton : PlaySoundButton {
//    private var _alarmSound: Sound? = nil
//
//    var alarmSound: Sound? {
//        get {
//            return self._alarmSound
//        }
//        set(alarmSound) {
//            if alarmSound?.id != self._alarmSound?.id {
//                self._alarmSound?.delegate = nil
//
//                self._alarmSound = alarmSound
//
//                if let alarmSound = self.alarmSound {
//                    alarmSound.stop()
//                }
//
//                self.delegate?.playSoundButton(self, alarmSoundDidChange: self._alarmSound)
//            }
//
//            self.resetContentViewsIfNeeded()
//        }
//    }
// }
