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

class SwayAnimation {
    let view: SDKView
    init(withView view: SDKView) {
        self.view = view
    }

    private(set) var isAnimating: Bool = false
    
    func startAnimating() {
        
        if self.isAnimating {
            return
        }
        
        self.isAnimating = true
        
        let duration = 0.5
        let repeatCount:Float = .greatestFiniteMagnitude

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
        
        let swayAmount: CGFloat = 0.45
        
        let rotation = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotation.values = [ -swayAmount, swayAmount ]
        rotation.calculationMode = .cubicPaced
        rotation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        rotation.repeatCount = repeatCount
        rotation.autoreverses = true
        rotation.fillMode = .forwards
        rotation.isRemovedOnCompletion = true
        rotation.duration = duration
        
        let layer = view.sdkLayer
        layer.position = CGPoint.init(x: self.view.frame.midX, y: self.view.frame.midY)
        layer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)

        layer.add(scaleAnimation, forKey: "sway-scale")
        layer.add(rotation, forKey: "sway-rotation")
    }
    
    func stopAnimating() {
        if self.isAnimating {
            self.view.sdkLayer.removeAnimation(forKey: "sway-scale")
            self.view.sdkLayer.removeAnimation(forKey: "sway-rotation")
            self.isAnimating = false
        }
    }
}
