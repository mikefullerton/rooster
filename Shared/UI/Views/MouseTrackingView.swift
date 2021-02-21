//
//  MouseTrackingView.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/21/21.
//

import Foundation
import AppKit

protocol MouseTrackingViewDelegate: AnyObject {
    
    func mouseTrackingView(_ view: MouseTrackingView,
                           mouseMovedAtLocation: CGPoint,
                           withEvent event: NSEvent)
    
    func mouseTrackingView(_ view: MouseTrackingView,
                           mouseEnteredWithEvent event: NSEvent)
    
    func mouseTrackingView(_ view: MouseTrackingView,
                           mouseExitedWithEvent event: NSEvent)
    
    func mouseTrackingView(_ view: MouseTrackingView,
                           mouseDownAtLocation: CGPoint,
                           withEvent event: NSEvent)
    
    func mouseTrackingView(_ view: MouseTrackingView,
                           mouseUpAtLocation: CGPoint,
                           withEvent event: NSEvent)
    
    func mouseTrackingView(_ view: MouseTrackingView,
                           mouseDraggedAtLocation: CGPoint,
                           withEvent event: NSEvent)
}

class MouseTrackingView : AnimateableView, MouseTrackingViewDelegate {
    
    weak var mouseTrackingDelegate: MouseTrackingViewDelegate?
    
    lazy var mouseTracker = MouseTracker(withView: self)
    
    var isMouseTrackingEnabled: Bool {
        get { return self.mouseTracker.isTrackingEnabled }
        set(value) {
            self.mouseTracker.isTrackingEnabled = value
        }
    }
    
    private(set) var isMouseInside: Bool = false {
        didSet {
            if oldValue != isMouseInside {
                self.mouseStateDidChange()
            }
        }
    }
    
    private(set) var isMouseDown: Bool = false {
        didSet {
            if oldValue != self.isMouseDown {
                self.mouseStateDidChange()
            }
        }
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isMouseTrackingEnabled = true
        self.mouseTrackingDelegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.isMouseTrackingEnabled = true
        self.mouseTrackingDelegate = self
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)

//        self.sdkBackgroundColor = NSColor.red
        
//        print("tracking: mouse entered")
        self.isMouseInside = true
        self.mouseTrackingDelegate?.mouseTrackingView(self,
                                                      mouseEnteredWithEvent: event)
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        self.isMouseInside = false

//        self.sdkBackgroundColor = NSColor.green

//        print("tracking: mouse exited")
        self.mouseTrackingDelegate?.mouseTrackingView(self,
                                                      mouseExitedWithEvent: event)
    }
    
    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
//        print("tracking: mouse moved")
        self.mouseTrackingDelegate?.mouseTrackingView(self,
                                                      mouseMovedAtLocation:self.convert(event.locationInWindow, from: nil),
                                                      withEvent: event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        print("tracking: mouse dragged")
        self.mouseTrackingDelegate?.mouseTrackingView(self,
                                                      mouseDraggedAtLocation: self.convert(event.locationInWindow, from: nil),
                                                      withEvent: event)
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        self.isMouseDown = true
        print("tracking: mouse down")
        self.mouseTrackingDelegate?.mouseTrackingView(self,
                                                      mouseDownAtLocation:self.convert(event.locationInWindow, from: nil),
                                                      withEvent: event);
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        self.isMouseDown = false
        print("tracking: mouse up")
        self.mouseTrackingDelegate?.mouseTrackingView(self,
                                                      mouseUpAtLocation:self.convert(event.locationInWindow, from: nil),
                                                      withEvent: event);
    }
    
    func mouseStateDidChange() {
        
    }

    func mouseTrackingView(_ view: MouseTrackingView,
                           mouseMovedAtLocation: CGPoint,
                           withEvent event: NSEvent) {
        
    }
    
    func mouseTrackingView(_ view: MouseTrackingView,
                           mouseEnteredWithEvent event: NSEvent) {
        
    }
    
    func mouseTrackingView(_ view: MouseTrackingView,
                           mouseExitedWithEvent event: NSEvent) {
        
    }
    
    func mouseTrackingView(_ view: MouseTrackingView,
                           mouseDownAtLocation: CGPoint,
                           withEvent event: NSEvent) {
        
    }
    
    func mouseTrackingView(_ view: MouseTrackingView,
                           mouseUpAtLocation: CGPoint,
                           withEvent event: NSEvent) {
        
    }
    
    func mouseTrackingView(_ view: MouseTrackingView,
                           mouseDraggedAtLocation: CGPoint,
                           withEvent event: NSEvent) {
        
    }
}
