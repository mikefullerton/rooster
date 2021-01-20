//
//  SoundVolumeView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/4/21.
//

import Foundation
import Cocoa

class SoundVolumeView : LabeledSliderView {
    
    init(fixedLabelWidth: CGFloat,
         sliderRightInset: CGFloat) {
        
        super.init(frame: CGRect.zero, title: "VOLUME".localized, fixedLabelWidth: fixedLabelWidth, sliderRightInset: sliderRightInset)
    
        self.slider.minimumValue = 0
        self.slider.maximumValue = 1.0
        
        let imageButton = FancyButton()
        imageButton.contentHorizontalAlignment = .leading
        imageButton.contentViews = [
            self.imageView(withName: "speaker.slash"),
            self.imageView(withName: "speaker"),
            self.imageView(withName: "speaker.wave.1"),
            self.imageView(withName: "speaker.wave.2"),
            self.imageView(withName: "speaker.wave.3")
        ]
        
        self.slider.maximumValueView = imageButton
        self.slider.addTarget(self, action: #selector(volumeDidChange(_:)), for: .valueChanged)
        self.slider.value = AppDelegate.instance.preferencesController.preferences.sounds.volume
        
        self.updateVolumeSliderImage(withSliderView: self.slider)
        
        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: PreferencesController.DidChangeEvent, object: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func imageView(withName name: String) -> NSImageView {
        let image = NSImage(systemName: name)
        let imageView = NSImageView(image: image)
        imageView.preferredSymbolConfiguration = NSImage.SymbolConfiguration(pointSize: 16,weight: .regular)
        imageView.tintColor = Theme(for: self).secondaryLabelColor
        return imageView
    }

    private func updateVolumeSliderImage(withSliderView sliderView: SliderView) {
        let soundPrefs = AppDelegate.instance.preferencesController.preferences.sounds

        if let button = sliderView.maximumValueView as? FancyButton {
            if soundPrefs.volume == 0 {
                button.contentViewIndex = 0
            } else if soundPrefs.volume < 0.33 {
                button.contentViewIndex = 1
            } else if soundPrefs.volume < 0.66 {
                button.contentViewIndex = 2
            } else if soundPrefs.volume < 1.0 {
                button.contentViewIndex = 3
            } else {
                button.contentViewIndex = 4
            }
        }
    }
    
    @objc func volumeDidChange(_ sender: UISlider) {
        var prefs = AppDelegate.instance.preferencesController.preferences
        var soundPrefs = prefs.sounds
        soundPrefs.volume = sender.value
        prefs.sounds = soundPrefs
        AppDelegate.instance.preferencesController.preferences = prefs
        self.updateVolumeSliderImage(withSliderView: self.slider)
    }
    
    @objc func preferencesDidChange(_ sender: Notification) {
        self.slider.value = AppDelegate.instance.preferencesController.preferences.sounds.volume
        self.updateVolumeSliderImage(withSliderView: self.slider)
    }

}
