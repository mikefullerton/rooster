//
//  DisclosureButton.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 4/18/21.
//
import AppKit
import Foundation

open class DisclosureButton: SystemButton {
    override open func createMouseEventSource() -> MouseEventSource {
        let button = super.createMouseEventSource()
        if  let button = button as? TrackingButton {
            button.isBordered = true
            button.setButtonType(.momentaryPushIn)
            button.bezelStyle = .roundedDisclosure
            button.contentTintColor = Theme(for: self).labelColor
        }
        return button
    }

    public func toggle() {
        if let cell = self.systemButton.cell {
            cell.userInterfaceLayoutDirection = cell.userInterfaceLayoutDirection == .leftToRight ? .rightToLeft : .leftToRight
        }
    }
}
