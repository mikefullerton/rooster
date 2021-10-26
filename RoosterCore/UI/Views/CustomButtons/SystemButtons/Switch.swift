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
        case off = 0
        case on = 1
        case mixed = 2

        public init?(withControlStateValue state: NSControl.StateValue) {
            switch state {
            case .off:
                self.init(rawValue: 0)

            case .on:
                self.init(rawValue: 1)

            case .mixed:
                self.init(rawValue: 2)

            default:
                return nil
            }
        }
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
            State(withControlStateValue: self.systemButton.state)!
        }
        set {
            switch newValue {
            case .on:
                self.systemButton.state = .on

            case .off:
                self.systemButton.state = .off

            case .mixed:
                self.systemButton.state = .mixed
            }
        }
    }

    public var allowsMixedState: Bool {
        get { self.systemButton.allowsMixedState }
        set { self.systemButton.allowsMixedState = newValue }
    }

    public var isOn: Bool {
        get { self.state == .on }
        set { self.state = newValue == true ? .on : .off }
    }

    public var isMixed: Bool {
        self.state == .mixed
    }
}
