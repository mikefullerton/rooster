//
//  AnimateableView.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/21/21.
//

import Foundation
import AppKit

class AnimateableLayer : CALayer {
    
    override var anchorPoint: CGPoint {
        get {
            return super.anchorPoint
        }
        set(new) {
            super.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        }
    }
}

class AnimateableView : NSView {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.wantsLayer = true
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.wantsLayer = true
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
    }
    
    convenience init() {
        self.init(frame:CGRect.zero)
    }
    
    override func makeBackingLayer() -> CALayer {
        return AnimateableLayer()
    }
}
