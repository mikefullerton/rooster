//
//  BarView.swift
//  Rooster-macOS
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

public class BlurView : SDKView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addBlurView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func addBlurView() {
        self.sdkBackgroundColor = SDKColor.clear
        
        let blurView = self.blurView
        
        if self.subviews.count > 0 {
            self.insertSubview(blurView, belowSubview: self.subviews[0])
        } else {
            self.addSubview(blurView)
        }

        blurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: self.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    public lazy var blurView: SDKView = {
        #if os(macOS)
        let visualEffectView = NSVisualEffectView(frame: CGRect.zero)
        visualEffectView.material =  .underWindowBackground //.titlebar //.headerView
        visualEffectView.blendingMode = .withinWindow
        visualEffectView.state = .active
        return visualEffectView
        #else
        
        #endif
    }()
    
}
