//
//  TrackingButton.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/25/21.
//

import Foundation

import Cocoa

public protocol TrackingButtonDelegate : AnyObject {
    func trackingButtonHandleMouseDown(_ button: TrackingButton)
    func trackingButtonHandleMouseUp(_ button: TrackingButton, mouseIsInside: Bool)
    func trackingButtonHandleMouseMovedWhilePressed(_ button: TrackingButton, mouseIsInside: Bool)
}

open class TrackingButton : NSButton {
    public weak var delegate: TrackingButtonDelegate?
    
    // I can't believe I have to write this code
    open override func mouseDown(with event: NSEvent) {
        
        if self.isEnabled == false {
            return
        }
        
        self.delegate?.trackingButtonHandleMouseDown(self)
        
        while true {
            if let event = self.window?.nextEvent(matching: [   .mouseMoved,
                                                                .leftMouseUp,
                                                                .leftMouseDragged,
                                                                .mouseExited,
                                                                .mouseExited ]) {
                
                let mouseLoc = self.convert(event.locationInWindow, from: nil)
                let isInside = self.bounds.contains(mouseLoc)
                
                if event.type == .leftMouseUp {
                    
                    self.delegate?.trackingButtonHandleMouseUp(self, mouseIsInside: isInside)
                    
                    if isInside {
                        self.performClick(self)
                    }
                    
                    break
                } else {
                    self.delegate?.trackingButtonHandleMouseMovedWhilePressed(self, mouseIsInside: isInside)
                }
                
            } else {
                break
            }
        }
    }
}
