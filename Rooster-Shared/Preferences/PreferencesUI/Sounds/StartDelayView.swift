//
//  SoundDelayView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/5/21.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public class StartDelayView: PreferenceSlider {
    private let preferencesUpdateHandler = PreferencesUpdateHandler()

    override init() {
        super.init()

        self.minimumValue = 0 // 1 play count
        self.maximumValue = 10

        self.value = min(self.maximumValue, Double(AppControllers.shared.preferences.soundPreferences.startDelay))

        self.label.title = "PLAY_DELAY".localized

        self.setViews(minValueView: self.label,
                      maxValueView: self.rhsButton,
                      insets: SDKEdgeInsets.ten,
                      minValueViewFixedWidth: self.fixedWidth,
                      maxValueViewFixedWidth: self.fixedWidth)

        self.updateVolumeSliderImage()

        self.tickMarkCount = 11
        self.tickMarkPosition = .trailing
        self.allowsTickMarkValuesOnly = true

        self.preferencesUpdateHandler.handler = { [weak self] _, _ in
            guard let self = self else {
                return
            }

            self.value = min(self.maximumValue, Double(AppControllers.shared.preferences.soundPreferences.startDelay))
            self.updateVolumeSliderImage()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    lazy var rhsButton: FancyButton = {
        let button = FancyButton()
        button.contentViewAlignment = .left
        button.animateableContent.contentViews = [
            self.label(withTitle: "None"),
            self.label(withTitle: "1 second"),
            self.label(withTitle: "2 seconds"),
            self.label(withTitle: "3 seconds"),
            self.label(withTitle: "4 seconds"),
            self.label(withTitle: "5 seconds"),
            self.label(withTitle: "6 seconds"),
            self.label(withTitle: "7 seconds"),
            self.label(withTitle: "8 seconds"),
            self.label(withTitle: "9 seconds"),
            self.label(withTitle: "10 seconds")
        ]

        button.setTarget(self, action: #selector(setMaxValue(_:)))
        return button
    }()

    private func label(withTitle title: String) -> SDKTextField {
        let label = HighlightableTextField()
        label.isEditable = false
        label.stringValue = title
        label.textColor = Theme(for: self).labelColor
        label.drawsBackground = false
        label.isBordered = false
        return label
    }

    private func updateVolumeSliderImage() {
        let startDelay = AppControllers.shared.preferences.soundPreferences.startDelay

        var index = startDelay
        if index >= self.rhsButton.animateableContent.viewCount {
            index = self.rhsButton.animateableContent.viewCount
        }
        self.rhsButton.animateableContent.viewIndex = index

        print("start delay: \(startDelay), index: \(index)")
    }

    @objc override public func sliderDidChange(_ sender: SDKSlider) {
        var soundPrefs = AppControllers.shared.preferences.soundPreferences

        let value = sender.doubleValue
        soundPrefs.startDelay = Int(value)

        AppControllers.shared.preferences.soundPreferences = soundPrefs
        self.updateVolumeSliderImage()
    }
}
