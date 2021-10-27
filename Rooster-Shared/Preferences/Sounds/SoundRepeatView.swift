//
//  SoundRepeatView.swift
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

public class SoundRepeatView: PreferenceSlider {
    private let preferencesUpdateHandler = PreferencesUpdateHandler()

    override init() {
        super.init()

        self.minimumValue = 1 // 1 play count
        self.maximumValue = Double(self.button.viewCount)
        self.value = min(self.maximumValue, Double(AppControllers.shared.preferences.soundPreferences.playCount))

        self.label.title = "PLAY_COUNT".localized

        self.setViews(minValueView: self.label,
                      maxValueView: self.button,
                      insets: SDKEdgeInsets.ten,
                      minValueViewFixedWidth: self.fixedWidth,
                      maxValueViewFixedWidth: self.fixedWidth)

        self.tickMarkCount = 6
        self.tickMarkPosition = .trailing
        self.allowsTickMarkValuesOnly = true

        self.updateVolumeSliderImage()

        self.preferencesUpdateHandler.handler = { [weak self] _, _ in
            guard let self = self else {
                return
            }

            self.value = min(self.maximumValue, Double(AppControllers.shared.preferences.soundPreferences.playCount))
            self.updateVolumeSliderImage()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    lazy var button: AnimateableButton = {
        let button = AnimateableButton()
        button.contentViewPosition = .leading
        button.contentViews = [
            HighlightableTextField(withButtonTitle: "Once"),
            HighlightableTextField(withButtonTitle: "Twice"),
            HighlightableTextField(withButtonTitle: "Three Times"),
            HighlightableTextField(withButtonTitle: "Four Times"),
            HighlightableTextField(withButtonTitle: "Five Times"),
            HighlightableTextField(withButtonTitle: "Infinite")
        ]

        button.setTarget(self, action: #selector(setMaxValue(_:)))

        return button
    }()

    private func updateVolumeSliderImage() {
        let playCount = AppControllers.shared.preferences.soundPreferences.playCount

        self.button.viewIndex = min(playCount - 1, self.button.maxViewIndex)
    }

    @objc override public func sliderDidChange(_ sender: SDKSlider) {
        var soundPrefs = AppControllers.shared.preferences.soundPreferences
        let value = sender.doubleValue
        if value == sender.maxValue {
            soundPrefs.playCount = SoundPreferences.RepeatEndlessly
        } else {
            soundPrefs.playCount = Int(value.rounded())
        }
        AppControllers.shared.preferences.soundPreferences = soundPrefs
        self.updateVolumeSliderImage()
    }
}
