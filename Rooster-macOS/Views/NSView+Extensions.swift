//
//  NSView+Extensions.swift
//  Rooster-macOSTests
//
//  Created by Mike Fullerton on 2/26/21.
//

import Foundation
import RoosterCore
import Cocoa

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
