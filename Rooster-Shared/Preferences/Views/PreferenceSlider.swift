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

open class PreferenceSlider: SliderView {
    public let fixedWidth: CGFloat = 100

    public init() {
        super.init(frame: CGRect.zero)

        self.setTarget(self, action: #selector(sliderDidChange(_:)))
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @objc open func sliderDidChange(_ sender: SDKSlider) {
    }

    public lazy var label: Button = {
        let button = Button(target: self,
                            action: #selector(setMinValue(_:)))
        //        button.alignment = .right
        button.contentTintColor = Theme(for: self).labelColor
        button.isEnabled = true
        return button
    }()
}
