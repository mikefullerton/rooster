//
//  SoundVolumeView.swift
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

class SoundVolumeView : PreferenceSlider {
    
    override init() {
        
        super.init()
    
        self.label.title = "VOLUME".localized
        
        self.minimumValue = 0
        self.maximumValue = 1.0
        self.value = Double(AppDelegate.instance.preferencesController.soundPreferences.volume)
        
        self.setViews(minValueView: self.label,
                      maxValueView: self.button,
                      insets: SDKEdgeInsets.ten,
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
        imageButton.contentViewAlignment = .left
        imageButton.contentViews = [
            self.imageView(withName: "speaker.slash"),
            self.imageView(withName: "speaker"),
            self.imageView(withName: "speaker.wave.1"),
            self.imageView(withName: "speaker.wave.2"),
            self.imageView(withName: "speaker.wave.3")
        ]
        
        imageButton.setTarget(self, action: #selector(setMaxValue(_:)))
        
        return imageButton
    } ()

    private func imageView(withName name: String) -> SDKImageView {
        guard let image = SDKImage(systemSymbolName: name, accessibilityDescription: name) else {
            return SDKImageView()
        }
        
        let imageView = SDKImageView(image: image)
        imageView.symbolConfiguration = SDKImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        imageView.contentTintColor = Theme(for: self).secondaryLabelColor
        return imageView
    }

    private func updateVolumeSliderImage() {
        let soundPrefs = AppDelegate.instance.preferencesController.soundPreferences

        if soundPrefs.volume <= 0.02 {
            self.button.contentViewIndex = 0
        } else if soundPrefs.volume < 0.20 {
            self.button.contentViewIndex = 1
        } else if soundPrefs.volume < 0.50 {
            self.button.contentViewIndex = 2
        } else if soundPrefs.volume < 0.95 {
            self.button.contentViewIndex = 3
        } else {
            self.button.contentViewIndex = 4
        }
    }
    
    @objc override func sliderDidChange(_ sender: SDKSlider) {
        var soundPrefs = AppDelegate.instance.preferencesController.soundPreferences
        soundPrefs.volume = sender.floatValue
        AppDelegate.instance.preferencesController.soundPreferences = soundPrefs
        self.updateVolumeSliderImage()
    }
    
    @objc override func preferencesDidChange(_ sender: Notification) {
        self.value = Double(AppDelegate.instance.preferencesController.soundPreferences.volume)
        self.updateVolumeSliderImage()
    }

}
