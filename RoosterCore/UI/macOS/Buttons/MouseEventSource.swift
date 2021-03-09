//
//  ButtonImp.swift
//  RoosterCore-macOS
//
//  Created by Mike Fullerton on 4/9/21.
//

import AppKit
import Foundation

public protocol MouseEventRecieving: AnyObject {
    func mouseEventSource(_ mouseEventSource: MouseEventSource,
                          mouseMoved mouseEvent: MouseEvent)

    func mouseEventSource(_ mouseEventSource: MouseEventSource,
                          mouseEntered mouseEvent: MouseEvent)

    func mouseEventSource(_ mouseEventSource: MouseEventSource,
                          mouseExited mouseEvent: MouseEvent)

    func mouseEventSource(_ mouseEventSource: MouseEventSource,
                          mouseDown mouseEvent: MouseEvent)

    func mouseEventSource(_ mouseEventSource: MouseEventSource,
                          mouseUp mouseEvent: MouseEvent)

    func mouseEventSource(_ mouseEventSource: MouseEventSource,
                          mouseDragged mouseEvent: MouseEvent)
}

public struct MouseEvent {
    let event: NSEvent
    let isMouseInside: Bool
    let isMouseDown: Bool
    let mouseLocation: CGPoint
}

public protocol MouseEventSource: SDKView {
    var mouseEventReceiver: MouseEventRecieving? { get set }
    var keyEquivalent: String { get set }
    var isEnabled: Bool { get set }
}
