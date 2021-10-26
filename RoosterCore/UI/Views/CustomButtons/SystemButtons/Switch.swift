//
//  Switch.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/6/21.
//

import AppKit
import Foundation

// swiftlint: disable identifier_name

open class Switch: SystemButton {
    public enum State: Int {
        case unknown = -1
        case off = 0
        case on = 1
        case mixed = 2
    }

    override open func createMouseEventSource() -> MouseEventSource {
        let button = super.createMouseEventSource()
        if  let button = button as? TrackingButton {
            button.isBordered = true
            button.setButtonType(.switch)
            button.bezelStyle = .rounded
        }

        if let button = button as? Button {
            button.contentTintColor = Theme(for: self).labelColor
        }

        return button
    }

    public var state: State {
        get {
            switch self.systemButton.state {
            case NSControl.StateValue.off:
                return Switch.State.off

            case NSControl.StateValue.on:
                return Switch.State.on

            case NSControl.StateValue.mixed:
                return Switch.State.mixed

            default:
                return Switch.State.unknown
            }
        }
        set {
            switch newValue {
            case Switch.State.on:
                self.systemButton.state = NSControl.StateValue.on

            case Switch.State.off:
                self.systemButton.state = NSControl.StateValue.off

            case Switch.State.mixed:
                self.systemButton.state = NSControl.StateValue.mixed

            case Switch.State.unknown:
                self.systemButton.state = NSControl.StateValue.off
            }

//            print("Switch \(self.title ?? "no title") set to \(String(describing: self.state))")
        }
    }

    public var allowsMixedState: Bool {
        get { self.systemButton.allowsMixedState }
        set { self.systemButton.allowsMixedState = newValue }
    }

    public var isOn: Bool {
        get { self.state == Switch.State.on }
        set { self.state = newValue == true ? Switch.State.on : Switch.State.off }
    }

    public var isMixed: Bool {
        self.state == Switch.State.mixed
    }
}
