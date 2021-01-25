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
        self.maximumValue = Double(button.contentViews.count - 1)
        self.value = min(self.maximumValue, Double(AppDelegate.instance.preferencesController.preferences.sounds.playCount))
        
        self.label.stringValue = "PLAY_COUNT".localized
        
        self.setViews(minValueView: self.label,
                      maxValueView: self.button,
                      insets: SDKEdgeInsets.ten,
                      minValueViewFixedWidth: self.fixedWidth,
                      maxValueViewFixedWidth: self.fixedWidth)
        
        self.updateVolumeSliderImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var button: FancyButton = {
        let button = FancyButton()
        button.alignment = .left
        button.contentViews = [
            button.defaultLabel(withTitle: "1x"),
            button.defaultLabel(withTitle: "2x"),
            button.defaultLabel(withTitle: "3x"),
            button.defaultLabel(withTitle: "4x"),
            button.defaultLabel(withTitle: "5x"),
            button.defaultLabel(withTitle: "Infinite"),
        ]
        
        return button
    } ()
    
    private func updateVolumeSliderImage() {
        let playCount = AppDelegate.instance.preferencesController.preferences.sounds.playCount
        
        var index = playCount
        if index >= button.contentViewCount {
            index = button.contentViewCount
        }
        self.button.contentViewIndex = index - 1
        
    }
    
    @objc override func sliderDidChange(_ sender: SDKSlider) {
        var prefs = AppDelegate.instance.preferencesController.preferences
        var soundPrefs = prefs.sounds
        
        let value = sender.doubleValue
        if value == sender.maxValue {
            soundPrefs.playCount = SoundPreference.RepeatEndlessly
        } else {
            soundPrefs.playCount = Int(value.rounded())
        }
        
        prefs.sounds = soundPrefs
        AppDelegate.instance.preferencesController.preferences = prefs
        self.updateVolumeSliderImage()
    }
    
    @objc override func preferencesDidChange(_ sender: Notification) {
        self.value = min(self.maximumValue, Double(AppDelegate.instance.preferencesController.preferences.sounds.playCount))
        self.updateVolumeSliderImage()
    }

}
