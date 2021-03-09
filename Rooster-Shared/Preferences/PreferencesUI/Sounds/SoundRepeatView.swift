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

class SoundRepeatView : PreferenceSlider {
    
    override init() {
        super.init()
        
        self.minimumValue = 1 // 1 play count
        self.maximumValue = Double(self.button.animateableContent.viewCount)
        self.value = min(self.maximumValue, Double(Controllers.preferences.soundPreferences.playCount))
        
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var button: FancyButton = {
        let button = FancyButton()
        button.contentViewAlignment = .left
        button.animateableContent.contentViews = [
            SDKTextField.buttonTextField(withTitle: "Once"),
            SDKTextField.buttonTextField(withTitle: "Twice"),
            SDKTextField.buttonTextField(withTitle: "Three Times"),
            SDKTextField.buttonTextField(withTitle: "Four Times"),
            SDKTextField.buttonTextField(withTitle: "Five Times"),
            SDKTextField.buttonTextField(withTitle: "Infinite")
        ]
        
        button.setTarget(self, action: #selector(setMaxValue(_:)))
        
        return button
    }()
    
    private func updateVolumeSliderImage() {
        let playCount = Controllers.preferences.soundPreferences.playCount
        
        self.button.animateableContent.viewIndex = min(playCount - 1, self.button.animateableContent.maxViewIndex)
    }
    
    @objc override func sliderDidChange(_ sender: SDKSlider) {
        var soundPrefs = Controllers.preferences.soundPreferences
        let value = sender.doubleValue
        if value == sender.maxValue {
            soundPrefs.playCount = SoundPreferences.RepeatEndlessly
        } else {
            soundPrefs.playCount = Int(value.rounded())
        }
        Controllers.preferences.soundPreferences = soundPrefs
        self.updateVolumeSliderImage()
    }
    
    @objc override func preferencesDidChange(_ sender: Notification) {
        self.value = min(self.maximumValue, Double(Controllers.preferences.soundPreferences.playCount))
        self.updateVolumeSliderImage()
    }

}
