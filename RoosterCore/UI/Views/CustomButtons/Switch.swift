//
//  Switch.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/6/21.
//

import Foundation

open class Switch: SystemButton {
    override open func createMouseEventSource() -> MouseEventSource {
        let button = super.createMouseEventSource()
        if  let button = button as? TrackingButton {
            button.isBordered = true
            button.setButtonType(.switch)
            button.bezelStyle = .rounded
            button.contentTintColor = Theme(for: self).labelColor
        }
        return button
    }

    public var isOn: Bool {
        get { self.systemButton.intValue == 1 }
        set { self.systemButton.intValue = newValue ? 1 : 0 }
    }
}
