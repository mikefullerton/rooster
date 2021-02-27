//
//  SoundDelayView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/5/21.
//

import Foundation
import UIKit

class StartDelayView : LabeledSliderView {
    
    init(fixedLabelWidth: CGFloat,
         sliderRightInset: CGFloat) {
        
        super.init(frame: CGRect.zero, title: "PLAY_DELAY".localized,
                   fixedLabelWidth: fixedLabelWidth,
                   sliderRightInset: sliderRightInset)
    
        let button = FancyButton()
        button.contentHorizontalAlignment = .leading
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
        
        self.slider.minimumValue = 0 // 1 play count
        self.slider.maximumValue = 10
        self.slider.maximumValueView = button
        self.slider.addTarget(self, action: #selector(repeatCountDidChange(_:)), for: .valueChanged)
        self.slider.value = min(self.slider.maximumValue, Float(Controllers.preferencesController.soundPreferences.startDelay))
        
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
            let startDelay = Controllers.preferencesController.soundPreferences.startDelay
            
            var index = startDelay
            if index >= button.contentViewCount {
                index = button.contentViewCount
            }
            button.contentViewIndex = index
            
            print("start delay: \(startDelay), index: \(index)")
        }
    }
    
    @objc func repeatCountDidChange(_ sender: UISlider) {
        var prefs = Controllers.preferencesController.preferences
        var soundPrefs = prefs.sounds
        
        let value = sender.value
        soundPrefs.startDelay = Int(value)
        
        prefs.sounds = soundPrefs
        Controllers.preferencesController.preferences = prefs
        self.updateVolumeSliderImage(withSliderView: self.slider)
    }
    
    @objc func preferencesDidChange(_ sender: Notification) {
        self.slider.value = min(self.slider.maximumValue, Float(Controllers.preferencesController.soundPreferences.startDelay))
        self.updateVolumeSliderImage(withSliderView: self.slider)
    }

}
