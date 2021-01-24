//
//  BarView.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/21/21.
//

import Foundation
import Cocoa

class BlurView : NSView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addBlurView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addBlurView() {
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.clear.cgColor
        
        let blurView = self.blurView
        
        if self.subviews.count > 0 {
            self.addSubview(blurView, positioned: .below, relativeTo: self.subviews[0])
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
    
    lazy var blurView: NSView = {
        let visualEffectView = NSVisualEffectView(frame: CGRect.zero)
        visualEffectView.material =  .underWindowBackground //.titlebar //.headerView
        visualEffectView.blendingMode = .withinWindow
        visualEffectView.state = .active
        return visualEffectView
    }()
    
}
