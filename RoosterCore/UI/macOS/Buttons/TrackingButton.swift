//
//  TrackingButton.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/25/21.
//

import Foundation

import Cocoa

open class TrackingButton: NSButton, Loggable, MouseEventSource {
    public weak var mouseEventReceiver: MouseEventRecieving?

    private var isTracking = false {
        didSet { self.logger.debug("isTracking set to: \(self.isTracking)") }
    }

    public func stopTrackingMouse() {
        self.logger.debug("Stopping tracking...")
        self.isTracking = false
    }

    // swiftlint:disable closure_body_length function_body_length

    // I can't believe I have to write this code
    override open func mouseDown(with event: NSEvent) {
        if self.isEnabled == false {
            return
        }

        guard let window = self.window else {
            return
        }

        self.logger.debug("Got mouse down")

        let mouseEvent = MouseEvent(event: event,
                                    isMouseInside: true,
                                    isMouseDown: true,
                                    mouseLocation: self.convert(event.locationInWindow, from: nil))

        self.mouseEventReceiver?.mouseEventSource(self,
                                                  mouseDown: mouseEvent)
        //
        //        var events: [NSEvent.EventTypeMask] = []
        //        for eventType in NSEvent.EventType.leftMouseDown.rawValue...NSEvent.EventType.otherMouseDragged.rawValue {
//            events.append(NSEvent.EventType(rawValue: eventType))
//        }
//
//        let events = NSEvent.EventTypeMask(events)

        let eventMask = NSEvent.EventTypeMask([
            .leftMouseDown,
            .leftMouseUp,
            .rightMouseUp,
            .rightMouseDown,
            .leftMouseDragged,
            .rightMouseDragged,
            .mouseMoved,
            .mouseEntered,
            .mouseExited,
            .otherMouseUp,
            .otherMouseDragged,
            .otherMouseDown
        ])

        self.isTracking = true

        window.trackEvents(matching: eventMask,
                           timeout: Date.distantFuture.timeIntervalSinceReferenceDate,
                           mode: .eventTracking) { [weak self] event, stop in
            guard let self = self else { return }

            if let event = event {
                if event.isMouseEvent {
//                    self.logger.debug("Got mouse event: \(String(describing: event))")

                    let mouseLoc = self.convert(event.locationInWindow, from: nil)
                    let isMouseInside = self.bounds.contains(mouseLoc)

                    let mouseEvent = MouseEvent(event: event,
                                                isMouseInside: isMouseInside,
                                                isMouseDown: true,
                                                mouseLocation: mouseLoc)

                    if event.isMouseUp {
                        self.logger.debug("Got mouse up")

                        self.performClick(self)
                        self.mouseEventReceiver?.mouseEventSource(self, mouseUp: mouseEvent)
                        self.isTracking = false
                    } else if event.isMouseMovedOrDragged {
                        self.mouseEventReceiver?.mouseEventSource(self, mouseMoved: mouseEvent)
                    } else {
                        self.logger.debug("got unexpected mouse event!")
                    }
                } else {
                    self.logger.debug("got non mouse event event: \(String(describing: event))")
                }
            } else {
                self.logger.debug("got nil event")
            }

            if !self.isTracking {
                stop.pointee = ObjCBool(true)
                self.logger.debug("Finished tracking mouse")
            }
        }

//        self.logger.debug("Finished tracking mouse")
    }

    // swiftlint:enable closure_body_length function_body_length

}

extension NSEvent {
    public var isMouseEvent: Bool {
        switch self.type {
        case .leftMouseDown,
             .leftMouseUp,
             .rightMouseUp,
             .rightMouseDown,
             .leftMouseDragged,
             .rightMouseDragged,
             .mouseMoved,
             .mouseEntered,
             .mouseExited,
             .otherMouseUp,
             .otherMouseDragged,
             .otherMouseDown:
            return true

        default:
            return false
        }
    }

    public var isMouseUp: Bool {
        switch self.type {
        case .leftMouseUp,
             .rightMouseUp,
             .otherMouseUp:
            return true

        default:
            return false
        }
    }

    public var isMouseMovedOrDragged: Bool {
        switch self.type {
        case .leftMouseDragged,
             .rightMouseDragged,
             .mouseMoved,
             .mouseEntered,
             .mouseExited,
             .otherMouseDragged:
            return true

        default:
            return false
        }
    }
}
