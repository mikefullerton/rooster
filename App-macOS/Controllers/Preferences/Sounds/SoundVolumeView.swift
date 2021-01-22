//
//  SoundVolumeView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/4/21.
//

import Foundation
import Cocoa

class SoundVolumeView : PreferenceSlider {
    
    override init() {
        
        super.init()
    
        self.label.stringValue = "VOLUME".localized
        
        self.minimumValue = 0
        self.maximumValue = 1.0
        self.value = Double(AppDelegate.instance.preferencesController.preferences.sounds.volume)
        
        self.setViews(minValueView: self.label,
                      maxValueView: self.button,
                      insets: NSEdgeInsets.ten,
                      minValueViewFixedWidth: self.fixedWidth,
                      maxValueViewFixedWidth: self.fixedWidth)

        self.updateVolumeSliderImage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: PreferencesController.DidChangeEvent, object: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var button: FancyButton = {
        let imageButton = FancyButton()
        imageButton.alignment = .left
        imageButton.contentViews = [
            self.imageView(withName: "speaker.slash"),
            self.imageView(withName: "speaker"),
            self.imageView(withName: "speaker.wave.1"),
            self.imageView(withName: "speaker.wave.2"),
            self.imageView(withName: "speaker.wave.3")
        ]
        return imageButton
    } ()

    private func imageView(withName name: String) -> NSImageView {
        guard let image = NSImage(systemSymbolName: name, accessibilityDescription: name) else {
            return NSImageView()
        }
        
        let imageView = NSImageView(image: image)
        imageView.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        imageView.contentTintColor = Theme(for: self).secondaryLabelColor
        return imageView
    }

    private func updateVolumeSliderImage() {
        let soundPrefs = AppDelegate.instance.preferencesController.preferences.sounds

        if soundPrefs.volume == 0 {
            self.button.contentViewIndex = 0
        } else if soundPrefs.volume < 0.33 {
            self.button.contentViewIndex = 1
        } else if soundPrefs.volume < 0.66 {
            self.button.contentViewIndex = 2
        } else if soundPrefs.volume < 1.0 {
            self.button.contentViewIndex = 3
        } else {
            self.button.contentViewIndex = 4
        }
    }
    
    @objc override func sliderDidChange(_ sender: NSSlider) {
        var prefs = AppDelegate.instance.preferencesController.preferences
        var soundPrefs = prefs.sounds
        soundPrefs.volume = sender.floatValue
        prefs.sounds = soundPrefs
        AppDelegate.instance.preferencesController.preferences = prefs
        self.updateVolumeSliderImage()
    }
    
    @objc override func preferencesDidChange(_ sender: Notification) {
        self.value = Double(AppDelegate.instance.preferencesController.preferences.sounds.volume)
        self.updateVolumeSliderImage()
    }

}
