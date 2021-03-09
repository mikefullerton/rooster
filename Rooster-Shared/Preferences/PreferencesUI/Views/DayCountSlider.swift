//
//  SoundDelayView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/5/21.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class DayCountSlider : PreferenceSlider {
    
    override init() {
        
        super.init()
    
        self.minimumValue = 1
        self.maximumValue = 7
        
        self.value = min(self.maximumValue, Double(Controllers.preferences.dataModel.dayCount))
        
        self.label.title = "Days"
        
        self.setViews(minValueView: self.label,
                      maxValueView: self.rhsButton,
                      insets: SDKEdgeInsets.ten,
                      minValueViewFixedWidth: self.fixedWidth,
                      maxValueViewFixedWidth: self.fixedWidth)

        self.updateVolumeSliderImage()
        
        self.tickMarkCount = 7
        self.tickMarkPosition = .trailing
        self.allowsTickMarkValuesOnly = true
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var rhsButton: FancyButton = {
        let button = FancyButton()
        button.contentViewAlignment = .left
        button.animateableContent.contentViews = [
            self.label(withTitle: "1 Day"),
            self.label(withTitle: "2 Days"),
            self.label(withTitle: "3 Days"),
            self.label(withTitle: "4 Days"),
            self.label(withTitle: "5 Days"),
            self.label(withTitle: "6 Days"),
            self.label(withTitle: "1 Week")
        ]
        
        button.setTarget(self, action: #selector(setMaxValue(_:)))
        return button
    }()
    
    
    private func label(withTitle title: String) -> SDKTextField {
        let label = SDKTextField()
        label.isEditable = false
        label.stringValue = title
        label.textColor = Theme(for: self).labelColor
        label.drawsBackground = false
        label.isBordered = false
        return label
    }

    private func updateVolumeSliderImage() {
        let index = Controllers.preferences.dataModel.dayCount - 1
        
//        if count >= self.rhsButton.animateableContent.viewCount {
//            count = self.rhsButton.animateableContent.viewCount
//        }
        self.rhsButton.animateableContent.viewIndex = index
            
//        print("start delay: \(startDelay), index: \(index)")
    }
    
    @objc override func sliderDidChange(_ sender: SDKSlider) {
        var prefs = Controllers.preferences.dataModel
        prefs.dayCount = Int(sender.doubleValue)
        
        Controllers.preferences.dataModel = prefs
        self.updateVolumeSliderImage()
    }
    
    @objc override func preferencesDidChange(_ sender: Notification) {
        self.value = min(self.maximumValue, Double(Controllers.preferences.dataModel.dayCount))
        self.updateVolumeSliderImage()
    }

}
