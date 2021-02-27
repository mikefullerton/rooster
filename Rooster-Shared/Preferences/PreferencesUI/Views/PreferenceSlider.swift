//
//  PreferenceSlider.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/21/21.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class PreferenceSlider : SliderView {
    
    let fixedWidth: CGFloat = 100
    
    init() {
        super.init(frame: CGRect.zero)
        
        self.setTarget(self, action: #selector(sliderDidChange(_:)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: PreferencesController.DidChangeEvent, object: nil)
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func sliderDidChange(_ sender: SDKSlider) {
        
        
    }
   
    @objc func preferencesDidChange(_ sender: Notification) {
        
    }
    
    lazy var label : SDKCustomButton = {
        let button = SDKCustomButton(title: "",
                                    target: self,
                                    action: #selector(setMinValue(_:)),
                                    toolTip: "")
        button.alignment = .right
        button.contentTintColor = Theme(for: self).labelColor
        button.isEnabled = true
        return button
    }()
    
    
    
}

