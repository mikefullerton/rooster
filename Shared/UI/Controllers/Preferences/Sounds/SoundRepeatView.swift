//
//  SoundRepeatView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/4/21.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class SoundRepeatView : PreferenceSlider {
    
    override init() {
        super.init()
        
        self.minimumValue = 1 // 1 play count
        self.maximumValue = Double(button.contentViews.count)
        self.value = min(self.maximumValue, Double(AppDelegate.instance.preferencesController.soundPreferences.playCount))
        
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
        button.alignment = .left
        button.contentViews = [
            button.defaultLabel(withTitle: "Once"),
            button.defaultLabel(withTitle: "Twice"),
            button.defaultLabel(withTitle: "Three Times"),
            button.defaultLabel(withTitle: "Four Times"),
            button.defaultLabel(withTitle: "Five Times"),
            button.defaultLabel(withTitle: "Infinite"),
        ]
        button.target = self
        button.action = #selector(setMaxValue(_:))
        return button
    } ()
    
    private func updateVolumeSliderImage() {
        let playCount = AppDelegate.instance.preferencesController.soundPreferences.playCount
        
        var index = playCount
        if index >= button.contentViewCount {
            index = button.contentViewCount
        }
        self.button.contentViewIndex = index - 1
        
    }
    
    @objc override func sliderDidChange(_ sender: SDKSlider) {
        var soundPrefs = AppDelegate.instance.preferencesController.soundPreferences
        let value = sender.doubleValue
        if value == sender.maxValue {
            soundPrefs.playCount = SoundPreferences.RepeatEndlessly
        } else {
            soundPrefs.playCount = Int(value.rounded())
        }
        AppDelegate.instance.preferencesController.soundPreferences = soundPrefs
        self.updateVolumeSliderImage()
    }
    
    @objc override func preferencesDidChange(_ sender: Notification) {
        self.value = min(self.maximumValue, Double(AppDelegate.instance.preferencesController.soundPreferences.playCount))
        self.updateVolumeSliderImage()
    }

}
