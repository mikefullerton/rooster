//
//  SDKView+SwayAnimation.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/26/21.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

func RadiansFromDegrees(_ degrees: Double) -> Double {
    return (degrees * .pi) / 180.0
}

func DegreesFromRadians(_ radians: Double) -> Double {
    return radians * 180.0 / .pi
}

class SwayAnimation : NSObject, Loggable {
    let view: SDKView
    init(withView view: SDKView) {
        self.view = view.animator()
        super.init()
    }

    private(set) var isAnimating: Bool = false

    private let duration = 0.5
    private let repeatCount:Float = .greatestFiniteMagnitude

    private lazy var scaleAnimation: CAKeyframeAnimation = {
        let scaleAmount:CGFloat = 0.08
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.values = [1.0 + scaleAmount, 1.0 - scaleAmount ]
        scaleAnimation.calculationMode = .cubicPaced
        scaleAnimation.duration = duration / 2.0 //duration / (Double(repeatCount) * 2.0)
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        scaleAnimation.repeatCount = repeatCount
        scaleAnimation.autoreverses = true
        scaleAnimation.fillMode = .forwards
        scaleAnimation.isRemovedOnCompletion = true
        return scaleAnimation
    }()
    
    private lazy var rotateAnimation: CAKeyframeAnimation = {
        let swayAmount: CGFloat = 0.45
        
        let rotation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        rotation.values = [ -swayAmount, swayAmount ]
        rotation.calculationMode = .cubicPaced
        rotation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        rotation.repeatCount = repeatCount
        rotation.autoreverses = true
        rotation.fillMode = .forwards
        rotation.isRemovedOnCompletion = true
        rotation.duration = duration
        return rotation
    }()
    
    
    func startAnimating() {
        
        if self.isAnimating {
            return
        }
        
        self.isAnimating = true
        
        let layer = self.view.sdkLayer
        
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.position = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY)
        
        CATransaction.begin()
        layer.add(self.scaleAnimation, forKey: "sway-scale")
        layer.add(self.rotateAnimation, forKey: "sway-rotation")
        CATransaction.commit()
    }
    
    func stopAnimating() {
        if self.isAnimating {
            let layer = self.view.sdkLayer
            layer.removeAnimation(forKey: "sway-scale")
            layer.removeAnimation(forKey: "sway-rotation")
            self.isAnimating = false
        }
    }
}


extension NSView {
    func rotate(amount: CGFloat) {
        if let layer = self.layer, let animatorLayer = self.animator().layer {
            layer.position = CGPoint(x: layer.frame.midX, y: layer.frame.midY)
            layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)

            NSAnimationContext.beginGrouping()
            NSAnimationContext.current.allowsImplicitAnimation = true
            animatorLayer.transform = CATransform3DMakeRotation(amount * CGFloat.pi / 2, 0, 0, 1)
            NSAnimationContext.endGrouping()
        }
    }
}
