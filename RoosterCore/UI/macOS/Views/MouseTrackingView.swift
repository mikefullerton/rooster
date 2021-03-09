//
//  MouseTrackingView.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/21/21.
//

import Foundation

import AppKit

open class MouseTrackingView: AnimateableView, MouseEventSource {
    public weak var mouseEventReceiver: MouseEventRecieving?

    private lazy var mouseTracker = MouseTracker(withView: self)

    public var isEnabled: Bool {
        get { self.mouseTracker.isTrackingEnabled }
        set { self.mouseTracker.isTrackingEnabled = newValue }
    }

    public var keyEquivalent: String = ""

    private var mouseDown = false

    public convenience init() {
        self.init(frame: CGRect.zero)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.isEnabled = true
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isEnabled = true
    }

    private func mouseEvent(fromEvent event: NSEvent) -> MouseEvent {
        let location = self.convert(event.locationInWindow, from: nil)
        let isInside = self.bounds.contains(location)

        // sometimes I'm not getting mouseup??
        let isMouseDown = NSEvent.pressedMouseButtons != 0 && self.mouseDown
        return MouseEvent(event: event,
                          isMouseInside: isInside,
                          isMouseDown: isMouseDown,
                          mouseLocation: location)
    }

    override open func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        self.mouseEventReceiver?.mouseEventSource(self, mouseEntered: self.mouseEvent(fromEvent: event))
    }

    override open func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        self.mouseEventReceiver?.mouseEventSource(self, mouseExited: self.mouseEvent(fromEvent: event))
    }

    override open func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        self.mouseEventReceiver?.mouseEventSource(self, mouseMoved: self.mouseEvent(fromEvent: event))
    }

    override open func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        self.mouseEventReceiver?.mouseEventSource(self, mouseDragged: self.mouseEvent(fromEvent: event))
    }

    override open func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        self.mouseDown = true
        self.mouseEventReceiver?.mouseEventSource(self, mouseDown: self.mouseEvent(fromEvent: event))
    }

    override open func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        self.mouseDown = false
        self.mouseEventReceiver?.mouseEventSource(self, mouseUp: self.mouseEvent(fromEvent: event))
    }
}
