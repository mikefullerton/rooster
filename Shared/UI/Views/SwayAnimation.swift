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

extension NSView
{
    func setAnchorPoint (anchorPoint:CGPoint)
    {
        if let layer = self.layer
        {
            var newPoint = CGPoint(x: self.bounds.size.width * anchorPoint.x, y: self.bounds.size.height * anchorPoint.y)
            var oldPoint = CGPoint(x: self.bounds.size.width * layer.anchorPoint.x, y: self.bounds.size.height * layer.anchorPoint.y)

            newPoint = newPoint.applying(layer.affineTransform())
            oldPoint = oldPoint.applying(layer.affineTransform())

            var position = layer.position

            position.x -= oldPoint.x
            position.x += newPoint.x

            position.y -= oldPoint.y
            position.y += newPoint.y

            layer.position = position
            layer.anchorPoint = anchorPoint
        }
    }
}

class SwayAnimation {
    
    let view: SDKView

    private var anchorPoint = CGPoint.zero
    private var running = false
    
    init(withView view: SDKView) {
        self.view = view
    }
    
    func rotate(_ angle: CGFloat) {
        let layer = self.view.sdkLayer
        if let animatorLayer = self.view.animator().layer {
            layer.position = CGPoint(x: layer.frame.midX, y: layer.frame.midY)
            layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)

            NSAnimationContext.beginGrouping()
            NSAnimationContext.current.allowsImplicitAnimation = true
            animatorLayer.transform = CATransform3DMakeRotation(angle * CGFloat.pi / 2, 0, 0, 1)
            NSAnimationContext.endGrouping()
        }
    }

    func start() {
        if self.running {
            return
        }
        
        guard let animatorLayer = self.view.animator().layer else {
            return
        }
        
        self.running = true
        
        self.anchorPoint = self.view.sdkLayer.anchorPoint
//            CGPoint(x: 0.5, y: 0.5)

        let duration = 1.0
        let repeatCount:Float = .greatestFiniteMagnitude

        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setCompletionBlock( {
            self.start()
        })
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.values = [1.0, 1.25, 1.0 ]
        scaleAnimation.calculationMode = .cubicPaced
        scaleAnimation.tensionValues = [ -1, 1, -1]
        scaleAnimation.duration = duration //duration / (Double(repeatCount) * 2.0)
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        scaleAnimation.repeatCount = repeatCount
        scaleAnimation.autoreverses = true
        scaleAnimation.fillMode = .forwards
        scaleAnimation.isRemovedOnCompletion = true

        let rotation = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotation.values = [ 0, 1.25, 0, -1.25, 0 ]
        rotation.calculationMode = .cubicPaced
        rotation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        rotation.repeatCount = repeatCount
        rotation.autoreverses = false
        rotation.fillMode = .forwards
        rotation.isRemovedOnCompletion = true

// can't get it to rotate around the center
        animatorLayer.position = CGPoint(x: self.view.frame.midX, y: self.view.frame.minY)
        animatorLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//        animatorLayer.add(rotation, forKey: "rotate")

        animatorLayer.add(scaleAnimation, forKey: "transform.scale.xy")
        
        CATransaction.commit()


//        NSAnimationContext.runAnimationGroup() { context in
//            context.duration = 0.25
//            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//            context.completionHandler = { [weak self] in
//                self?.swayForward()
//            }
//
//            let degrees:CGFloat = 50.0
//            let layer = self.view.sdkLayer
//
//            var rotationAndPerspectiveTransform = CATransform3DIdentity
//            rotationAndPerspectiveTransform.m34 = 1.0 / -400;
//            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, degrees * .pi / 180.0, 0, -1.0, 0.0);
//            layer.transform = rotationAndPerspectiveTransform;
//        }
    }
    
    func stop() {
        self.running = false
    }
    
    private func didStop() {
        self.view.sdkLayer.anchorPoint = self.anchorPoint
    }
    
    private func swayForward() {
        if !self.running {
            self.didStop()
        }

        NSAnimationContext.runAnimationGroup() { context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            context.completionHandler = { [weak self] in
                self?.swayBackward()
            }

            let degrees:CGFloat = 50.0
            let layer = self.view.sdkLayer
            var rotationAndPerspectiveTransform = CATransform3DIdentity;
            rotationAndPerspectiveTransform.m34 = 1.0 / -400;
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, degrees * .pi / 180.0, 1.0, 0.0, 0.0);
            layer.transform = rotationAndPerspectiveTransform;
        }
    }
    
    private func swayBackward() {
        
        if !self.running {
            self.didStop()
        }
        
        NSAnimationContext.runAnimationGroup() { context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            context.completionHandler = { [weak self] in
                self?.swayForward()
            }

            let degrees:CGFloat = 50.0
            let layer = self.view.sdkLayer
            var rotationAndPerspectiveTransform = CATransform3DIdentity;
            rotationAndPerspectiveTransform.m34 = 1.0 / -400;
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, degrees * .pi / 180.0, 0.0, 0.0, 0.0);
            layer.transform = rotationAndPerspectiveTransform;
        }
    }
}

/*
 //        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
 //        pulseAnimation.duration = 0.4
 //        pulseAnimation.fromValue = 0.5
 //        pulseAnimation.toValue = 1.0
 //        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
 //        pulseAnimation.autoreverses = true
 //        pulseAnimation.repeatCount = .greatestFiniteMagnitude
 //        view.layer.add(pulseAnimation, forKey: nil)
 //
 //        let pulse = CASpringAnimation(keyPath: "transform.scale")
 //        pulse.duration = 0.4
 //        pulse.fromValue = 1.0
 //        pulse.toValue = 1.12
 //        pulse.autoreverses = true
 //        pulse.repeatCount = .infinity
 //        pulse.initialVelocity = 0.5
 //        pulse.damping = 0.8
 //        view.layer.add(pulse, forKey: nil)
 */


/*
 
 
 In order to do this you have to do a couple of things beforehand such as setting the layer anchor point to (0.5,0.0). like the following:

 swaybtn.layer.anchorPoint = CGPointMake(0.5, 0.0);

 And then make a function that gets called when the button is tapped which starts the backwards sway animation, another which sways forward, and a last one that moves back to the original position. The degrees you specify is how far the sway will go and the second number in the rotationAndPerspectiveTransform is the direction the sway will go. The functions are as follow
 
 -(void)sway:(id)sender{

 CGFloat degrees = 50.0;

 CALayer *layer;
 layer = swaybtn.layer;

 CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;

 [UIView beginAnimations:nil context:NULL];
 [UIView setAnimationDuration:0.25];
 [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
 [UIView setAnimationDelegate:self];
 [UIView setAnimationDidStopSelector:@selector(moveForward)];

 rotationAndPerspectiveTransform.m34 = 1.0 / -400;
 rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, degrees * M_PI / 180.0f, -1.0f, 0.0f, 0.0f);
 layer.transform = rotationAndPerspectiveTransform;

 [UIView commitAnimations];

 }

 -(void)moveForward{

 CALayer *layer;
 layer = swaybtn.layer;

 CGFloat degrees = 50.0;

 CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;

 [UIView beginAnimations:@"swayforward" context:NULL];
 [UIView setAnimationDuration:0.5];
 [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
 [UIView setAnimationDelegate:self];
 [UIView setAnimationDidStopSelector:@selector(moveBack)];

 rotationAndPerspectiveTransform.m34 = 1.0 / -400;
 rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, degrees * M_PI / 180.0f, 1.0f, 0.0f, 0.0f);
 layer.transform = rotationAndPerspectiveTransform;

 [UIView commitAnimations];

 }

 -(void)moveBack{

 CALayer *layer;
 layer = swaybtn.layer;

 CGFloat degrees = 50.0;

 CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;

 [UIView beginAnimations:@"moveback" context:NULL];
 [UIView setAnimationDuration:0.25];
 [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

 rotationAndPerspectiveTransform.m34 = 1.0 / -400;
 rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, degrees * M_PI / 180.0f, 0.0f, 0.0f, 0.0f);
 layer.transform = rotationAndPerspectiveTransform;

 [UIView commitAnimations];

 }

 */
