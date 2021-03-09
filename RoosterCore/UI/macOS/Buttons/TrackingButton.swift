//
//  TrackingButton.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/25/21.
//

import Foundation

import Cocoa

public protocol TrackingButtonDelegate : AnyObject {
    func trackingButton(_ buttton: TrackingButton, didHighlight isHighlighted: Bool)
}

open class TrackingButton : NSButton {
    public weak var delegate: TrackingButtonDelegate?
    
    // I can't believe I have to write this code
    open override func mouseDown(with event: NSEvent) {
        
        if self.isEnabled == false {
            return
        }
        
        self.isHighlighted = true
        while true {
            let event = self.window?.nextEvent(matching: [ .leftMouseUp, .leftMouseDragged, .mouseExited, .mouseExited ])
            let mouseLoc = self.convert((event?.locationInWindow)!, from: nil)
            let isInside = self.bounds.contains(mouseLoc)
            self.isHighlighted = isInside
            if event?.type == .leftMouseUp {
                
                if isInside {
                    self.performClick(self)
                }
                
                self.isHighlighted = false
                break
            }
        }
    }
    
    open override var isHighlighted: Bool {
        get { return super.isHighlighted }
        set(highlighted) {
            
            super.isHighlighted = highlighted
            
            if let delegate = self.delegate {
                delegate.trackingButton(self, didHighlight: highlighted)
            }
            
            print("highlighted changed to: \(highlighted)")
        }
    }
  
}
