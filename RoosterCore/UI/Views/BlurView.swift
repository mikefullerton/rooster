//
//  BarView.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/21/21.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

open class BlurView: AnimateableView {
    override public init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)

        self.addBlurView(withMaterial: .underWindowBackground,
                         blendingMode: .withinWindow)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.addBlurView(withMaterial: .underWindowBackground,
                         blendingMode: .withinWindow)
    }

    public init(withMaterial material: NSVisualEffectView.Material,
                blendingMode: NSVisualEffectView.BlendingMode) {
        super.init(frame: CGRect.zero)

        self.addBlurView(withMaterial: material,
                         blendingMode: blendingMode)
    }

    public var blendingMode: NSVisualEffectView.BlendingMode {
        get { self.visualEffectView.blendingMode }
        set { self.visualEffectView.blendingMode = newValue }
    }

    public var material: NSVisualEffectView.Material {
        get { self.visualEffectView.material }
        set { self.visualEffectView.material = newValue }
    }

    private func addBlurView(withMaterial material: NSVisualEffectView.Material,
                             blendingMode: NSVisualEffectView.BlendingMode) {
        self.sdkBackgroundColor = SDKColor.clear

        let visualEffectView = self.visualEffectView
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode

        if !self.subviews.isEmpty {
            self.addSubview(visualEffectView, positioned: .below, relativeTo: self.subviews[0], constraints: [ .fill ])
        } else {
            self.addSubview(visualEffectView, constraints: [ .fill ])
        }

        self.addSubview(visualEffectView, constraints: [ .fill ])
    }

    public lazy var visualEffectView: NSVisualEffectView = {
        #if os(macOS)
        let visualEffectView = NSVisualEffectView(frame: CGRect.zero)
        visualEffectView.state = .active
        return visualEffectView
        #else

        #endif
    }()
}
