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

class BlurView : SDKView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addBlurView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addBlurView() {
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
    
    lazy var blurView: SDKView = {
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
