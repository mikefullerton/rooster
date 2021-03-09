//
//  SoundVolumeView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/4/21.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public class SoundVolumeView: PreferenceSlider {
    private let preferencesUpdateHandler = PreferencesUpdateHandler()

    override init() {
        super.init()

        self.label.title = "VOLUME".localized

        self.minimumValue = 0
        self.maximumValue = 1.0
        self.value = Double(AppControllers.shared.preferences.soundPreferences.volume)

        self.setViews(minValueView: self.label,
                      maxValueView: self.button,
                      insets: SDKEdgeInsets.ten,
                      minValueViewFixedWidth: self.fixedWidth,
                      maxValueViewFixedWidth: self.fixedWidth)

        self.updateVolumeSliderImage()

        self.preferencesUpdateHandler.handler = { [weak self] _, _ in
            guard let self = self else {
                return
            }

            self.mute = true
            self.value = Double(AppControllers.shared.preferences.soundPreferences.volume)
            self.mute = false

            self.updateVolumeSliderImage()
       }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    lazy var button: FancyButton = {
        let imageButton = FancyButton()
        imageButton.contentViewAlignment = .left
        imageButton.animateableContent.contentViews = [
            self.imageView(withName: "speaker.slash"),
            self.imageView(withName: "speaker"),
            self.imageView(withName: "speaker.wave.1"),
            self.imageView(withName: "speaker.wave.2"),
            self.imageView(withName: "speaker.wave.3")
        ]

        imageButton.setTarget(self, action: #selector(setMaxValue(_:)))

        return imageButton
    }()

    private func imageView(withName name: String) -> SDKImageView {
        guard let image = SDKImage(systemSymbolName: name, accessibilityDescription: name)?
                            .withSymbolConfiguration(NSImage.SymbolConfiguration(scale: .large))?
                            .tint(color: Theme(for: self).secondaryLabelColor) else {
            return SDKImageView()
        }

        let imageView = HighlightableImageView(image: image)
        return imageView
    }

    private lazy var sound: SoundFile = {
        let sound = SoundFolder.instance.findSoundFiles(forName: "Rooster Crowing")
        return sound[0]
    }()

    private var mute = false

    private func playSound() {
        if !self.mute && !self.sound.soundPlayer.isPlaying {
            self.sound.soundPlayer.play(withBehavior: SoundBehavior(playCount: 1, timeBetweenPlays: 0, fadeInTime: 0))
        }
    }

    private func updateVolumeSliderImage() {
        let soundPrefs = AppControllers.shared.preferences.soundPreferences

        var viewIndex = self.button.animateableContent.viewIndex

        if soundPrefs.volume <= 0.02 {
            viewIndex = 0
        } else if soundPrefs.volume < 0.20 {
            viewIndex = 1
        } else if soundPrefs.volume < 0.50 {
            viewIndex = 2
        } else if soundPrefs.volume < 0.95 {
            viewIndex = 3
        } else {
            viewIndex = 4
        }

        if self.button.animateableContent.viewIndex != viewIndex {
            self.button.animateableContent.viewIndex = viewIndex
        }
    }

    @objc override public func sliderDidChange(_ sender: SDKSlider) {
        var soundPrefs = AppControllers.shared.preferences.soundPreferences
        soundPrefs.volume = sender.floatValue
        AppControllers.shared.preferences.soundPreferences = soundPrefs
        self.updateVolumeSliderImage()

        if soundPrefs.volume > 0.02 {
            self.playSound()
        } else {
            self.sound.soundPlayer.stop()
        }
    }
}
