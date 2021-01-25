//
//  SoundDelayView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/5/21.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class StartDelayView : PreferenceSlider {
    
    override init() {
        
        super.init()
    
        self.minimumValue = 0 // 1 play count
        self.maximumValue = 10
        
        self.value = min(self.maximumValue, Double(AppDelegate.instance.preferencesController.preferences.sounds.startDelay))
        
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
            self.label(withTitle: "10 seconds"),
        ]
        
        return button
    } ()
    
    
    private func label(withTitle title: String) -> SDKTextField {
        let label = SDKTextField()
        label.isEditable = false
        label.stringValue = title
        label.textColor = Theme(for: self).secondaryLabelColor
        label.drawsBackground = false
        label.isBordered = false
        return label
    }

    private func updateVolumeSliderImage() {
        let startDelay = AppDelegate.instance.preferencesController.preferences.sounds.startDelay
        
        var index = startDelay
        if index >= button.contentViewCount {
            index = button.contentViewCount
        }
        self.button.contentViewIndex = index
            
        print("start delay: \(startDelay), index: \(index)")
    }
    
    @objc override func sliderDidChange(_ sender: SDKSlider) {
        var prefs = AppDelegate.instance.preferencesController.preferences
        var soundPrefs = prefs.sounds
        
        let value = sender.doubleValue
        soundPrefs.startDelay = Int(value)
        
        prefs.sounds = soundPrefs
        AppDelegate.instance.preferencesController.preferences = prefs
        self.updateVolumeSliderImage()
    }
    
    @objc override func preferencesDidChange(_ sender: Notification) {
        self.value = min(self.maximumValue, Double(AppDelegate.instance.preferencesController.preferences.sounds.startDelay))
        self.updateVolumeSliderImage()
    }

}
