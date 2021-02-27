//
//  NSView+CrossPlatform.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/24/21.
//

import Foundation
import RoosterCore
import Cocoa

extension NSView {
    
    var sdkBackgroundColor: SDKColor? {
        get {
            if let cgColor = self.sdkLayer.backgroundColor {
                return SDKColor(cgColor: cgColor)
            }
            
            return nil
        }
        set(color) {
            if color != nil {
                self.sdkLayer.backgroundColor = color!.cgColor
            } else {
                self.sdkLayer.backgroundColor = nil
            }
        }
    }
    
    func insertSubview(_ view: SDKView, aboveSubview otherView: SDKView) {
        self.addSubview(view, positioned: .above, relativeTo: otherView)
    }

    func insertSubview(_ view: SDKView, belowSubview otherView: SDKView) {
        self.addSubview(view, positioned: .below, relativeTo: otherView)
    }
    
    var sdkLayer : CALayer {
        self.wantsLayer = true
        return self.layer!
    }

}
