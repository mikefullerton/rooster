//
//  AnimateableView.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/21/21.
//

import Foundation

import AppKit

open class AnimateableLayer : CALayer {
    
    public var isAnimating: Bool = false {
        didSet {
            if (self.isAnimating) {
                super.anchorPoint = self.animationAnchorPoint
            } else {
                super.anchorPoint = self.previousAnchorPoint
            }
        }
    }
    
    private var previousAnchorPoint: CGPoint = CGPoint.zero
    
    public var animationAnchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)
    
    open override var anchorPoint: CGPoint {
        get {
            if (self.isAnimating) {
                return self.animationAnchorPoint
            } else {
                return super.anchorPoint
            }
        }
        set(anchorPoint) {
            if (!self.isAnimating) {
                super.anchorPoint = anchorPoint
                self.previousAnchorPoint = anchorPoint
            }
        }
    }
    
    open override func add(_ anim: CAAnimation, forKey key: String?) {
        self.isAnimating = true
        super.add(anim, forKey: key)
    }
    
    open override func removeAnimation(forKey key: String) {
        super.removeAnimation(forKey: key)
        let keys = self.animationKeys()
        
        if keys == nil || keys!.count == 0 {
            self.isAnimating = false
        }
    }
    
    open override func removeAllAnimations() {
        super.removeAllAnimations()
        self.isAnimating = false
    }
}

open class AnimateableView : NSView {
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.wantsLayer = true
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.wantsLayer = true
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
    }
    
    public convenience init() {
        self.init(frame:CGRect.zero)
    }
    
    open override func makeBackingLayer() -> CALayer {
        return AnimateableLayer()
    }
}
