//
//  AnimateableView.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/21/21.
//

import Foundation

import AppKit

open class AnimateableLayer: CALayer {
    public var isAnimating = false {
        didSet {
            if self.isAnimating {
                super.anchorPoint = self.animationAnchorPoint
            } else {
                super.anchorPoint = self.previousAnchorPoint
            }
        }
    }

    private var previousAnchorPoint = CGPoint.zero

    public var animationAnchorPoint = CGPoint(x: 0.5, y: 0.5)

    override open var anchorPoint: CGPoint {
        get {
            if self.isAnimating {
                return self.animationAnchorPoint
            } else {
                return super.anchorPoint
            }
        }
        set(anchorPoint) {
            if !self.isAnimating {
                super.anchorPoint = anchorPoint
                self.previousAnchorPoint = anchorPoint
            }
        }
    }

    override open func add(_ anim: CAAnimation, forKey key: String?) {
        self.isAnimating = true
        super.add(anim, forKey: key)
    }

    override open func removeAnimation(forKey key: String) {
        super.removeAnimation(forKey: key)
        if let keys = self.animationKeys(),
           !keys.isEmpty {
            self.isAnimating = false
        }
    }

    override open func removeAllAnimations() {
        super.removeAllAnimations()
        self.isAnimating = false
    }
}

open class AnimateableView: NSView {
    override public init(frame frameRect: NSRect) {
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
        self.init(frame: CGRect.zero)
    }

    override open func makeBackingLayer() -> CALayer {
        AnimateableLayer()
    }
}
