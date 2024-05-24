//
//  ButtonBackgroundView.swift
//  RoosterCore-macOS
//
//  Created by Mike Fullerton on 4/23/21.
//

import Foundation
#if os(macOS)
import Cocoa
import AppKit
#else
import UIKit
#endif

public class ButtonBackgroundView: AnimateableView {
    public var highlighted = false {
        didSet {
            self.updateToggled()
        }
    }

    public convenience init() {
        self.init(frame: CGRect.zero)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        self.sdkBackgroundColor = SDKColor.clear

//        self.addSubview(self.visualEffectView, constraints: [ .fill ])
        self.sdkLayer.cornerRadius = 4.0
        self.sdkLayer.borderWidth = 2.0
        self.updateToggled()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.sdkLayer.cornerRadius = 4.0
        self.sdkLayer.borderWidth = 2.0
        self.updateToggled()
    }

    private func updateToggled() {
        if self.highlighted {
            self.sdkLayer.borderColor = NSColor.selectedControlColor.cgColor
//            self.visualEffectView.isHidden = false
        } else {
//            self.visualEffectView.isHidden = true
            self.sdkLayer.borderColor = NSColor.separatorColor.cgColor
        }

        self.visualEffectView.isEmphasized = self.highlighted
    }

    public lazy var visualEffectView: NSVisualEffectView = {
        let view = NSVisualEffectView(frame: CGRect.zero)
        view.state = .active
        view.material = .selection
        view.blendingMode = .behindWindow
        return view
    }()
}
