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

class SoundVolumeView : PreferenceSlider {
    
    override init() {
        
        super.init()
    
        self.label.title = "VOLUME".localized
        
        self.minimumValue = 0
        self.maximumValue = 1.0
        self.value = Double(Controllers.preferences.soundPreferences.volume)
        
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
        guard let image = SDKImage(systemSymbolName: name, accessibilityDescription: name) else {
            return SDKImageView()
        }
        
        let imageView = SDKImageView(image: image)
        imageView.symbolConfiguration = SDKImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        imageView.contentTintColor = Theme(for: self).secondaryLabelColor
        return imageView
    }

    private lazy var sound: SoundFile = {
        let sound = SoundFolder.instance.findSoundFiles(forName: "Rooster Crowing")
        return sound[0]
    }()
    
    private var mute: Bool = false
    
    private func playSound() {
        if !self.mute && !self.sound.soundPlayer.isPlaying {
            self.sound.soundPlayer.play(withBehavior: SoundBehavior(playCount: 1, timeBetweenPlays: 0, fadeInTime: 0))
        }
    }
    
    private func updateVolumeSliderImage() {
        let soundPrefs = Controllers.preferences.soundPreferences

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
    
    @objc override func sliderDidChange(_ sender: SDKSlider) {
        var soundPrefs = Controllers.preferences.soundPreferences
        soundPrefs.volume = sender.floatValue
        Controllers.preferences.soundPreferences = soundPrefs
        self.updateVolumeSliderImage()
        
        if soundPrefs.volume > 0.02 {
            self.playSound()
        } else {
            self.sound.soundPlayer.stop()
        }
    }
    
    @objc override func preferencesDidChange(_ sender: Notification) {
        self.mute = true
        self.value = Double(Controllers.preferences.soundPreferences.volume)
        self.mute = false
        
        self.updateVolumeSliderImage()
    }

}
