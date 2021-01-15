//
//  SoundRepeatView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/4/21.
//

import Foundation
import UIKit

class SoundRepeatView : LabeledSliderView {
    
    init(fixedLabelWidth: CGFloat,
         sliderRightInset: CGFloat) {
        
        super.init(frame: CGRect.zero, title: "Play Count", fixedLabelWidth: fixedLabelWidth, sliderRightInset: sliderRightInset)
    
        
        let button = FancyButton()
        button.contentHorizontalAlignment = .leading
        button.contentViews = [
            self.label(withTitle: "1x"),
            self.label(withTitle: "2x"),
            self.label(withTitle: "3x"),
            self.label(withTitle: "4x"),
            self.label(withTitle: "5x"),
            self.label(withTitle: "Infinite"),
        ]
        
        self.slider.minimumValue = 1 // 1 play count
        self.slider.maximumValue = Float(button.contentViews.count - 1)
        self.slider.maximumValueView = button
        self.slider.addTarget(self, action: #selector(repeatCountDidChange(_:)), for: .valueChanged)
        self.slider.value = min(self.slider.maximumValue, Float(AppDelegate.instance.preferencesController.preferences.sounds.playCount))
        
        self.updateVolumeSliderImage(withSliderView: self.slider)
        
        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: PreferencesController.DidChangeEvent, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func label(withTitle title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.textColor = Theme(for: self).secondaryLabelColor
        return label
    }

    private func updateVolumeSliderImage(withSliderView sliderView: SliderView) {
        if let button = sliderView.maximumValueView as? FancyButton {
            let playCount = AppDelegate.instance.preferencesController.preferences.sounds.playCount
            
            var index = playCount
            if index >= button.contentViewCount {
                index = button.contentViewCount
            }
            button.contentViewIndex = index - 1
        }
    }
    
    @objc func repeatCountDidChange(_ sender: UISlider) {
        var prefs = AppDelegate.instance.preferencesController.preferences
        var soundPrefs = prefs.sounds
        
        let value = sender.value
        if value == sender.maximumValue {
            soundPrefs.playCount = SoundPreference.RepeatEndlessly
        } else {
            soundPrefs.playCount = Int(value.rounded())
        }
        
        prefs.sounds = soundPrefs
        AppDelegate.instance.preferencesController.preferences = prefs
        self.updateVolumeSliderImage(withSliderView: self.slider)
    }
    
    @objc func preferencesDidChange(_ sender: Notification) {
        self.slider.value = min(self.slider.maximumValue, Float(AppDelegate.instance.preferencesController.preferences.sounds.playCount))
        self.updateVolumeSliderImage(withSliderView: self.slider)
    }

}
