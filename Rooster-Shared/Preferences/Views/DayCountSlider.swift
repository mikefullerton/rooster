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

public class DayCountSlider: PreferenceSlider {
    private let preferencesUpdateHandler = PreferencesUpdateHandler()

    static var prefs: CalendarPreferences {
        get { AppControllers.shared.preferences.calendar }
        set { AppControllers.shared.preferences.calendar = newValue }
    }

    override init() {
        super.init()

        self.minimumValue = 1
        self.maximumValue = 7

        self.value = min(self.maximumValue, Double(Self.prefs.scheduleBehavior.visibleDayCount))

        self.label.title = "Days"

        self.setViews(minValueView: self.label,
                      maxValueView: self.rhsButton,
                      insets: SDKEdgeInsets.ten,
                      minValueViewFixedWidth: self.fixedWidth,
                      maxValueViewFixedWidth: self.fixedWidth)

        self.updateSliderImage()

        self.tickMarkCount = 7
        self.tickMarkPosition = .trailing
        self.allowsTickMarkValuesOnly = true

        self.preferencesUpdateHandler.handler = { [weak self] newPrefs, _ in
            guard let self = self else {
                return
            }

            self.value = min(self.maximumValue, Double(newPrefs.calendar.scheduleBehavior.visibleDayCount))
            self.updateSliderImage()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    lazy var rhsButton: AnimateableButton = {
        let button = AnimateableButton()
        button.contentViewPosition = .leading
        button.contentViews = [
            self.label(withTitle: "1 Day"),
            self.label(withTitle: "2 Days"),
            self.label(withTitle: "3 Days"),
            self.label(withTitle: "4 Days"),
            self.label(withTitle: "5 Days"),
            self.label(withTitle: "6 Days"),
            self.label(withTitle: "1 Week")
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

    private func updateSliderImage() {
        let index = Self.prefs.scheduleBehavior.visibleDayCount - 1

//        if count >= self.rhsButton.animateableContent.viewCount {
//            count = self.rhsButton.animateableContent.viewCount
//        }
        self.rhsButton.viewIndex = index

//        print("start delay: \(startDelay), index: \(index)")
    }

    @objc override public func sliderDidChange(_ sender: SDKSlider) {
        Self.prefs.scheduleBehavior.visibleDayCount = Int(sender.doubleValue)
        self.updateSliderImage()
    }
}
