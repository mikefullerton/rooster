//
//  SystemButton.swift
//  RoosterCore-macOS
//
//  Created by Mike Fullerton on 4/9/21.
//

import AppKit
import Foundation

open class SystemButton: Button {
    internal lazy var systemButton = TrackingButton()

    override open func createMouseEventSource() -> MouseEventSource {
        let button = self.systemButton
        button.isTransparent = false
        if let title = self.title {
            button.title = title
        }

        if let attributedTitle = self.attributedTitle {
            button.attributedStringValue = attributedTitle
        }

        if let image = self.image {
            button.image = image
        }

        button.isBordered = true
        button.setButtonType(.momentaryPushIn)
        button.bezelStyle = .rounded
        return button
    }

    override open func createContentView() -> SDKView? {
        nil
    }

    override open func contentsDidChange() {
        if let title = self.title {
            self.systemButton.title = title
        } else if self.systemButton.stringValue.isEmpty {
            self.systemButton.title = ""
        }

        if let attributedTitle = self.attributedTitle {
            self.systemButton.attributedTitle = attributedTitle
        }

        self.systemButton.image = self.image
    }

    override public var contentTintColor: SDKColor? {
        didSet {
            self.systemButton.contentTintColor = contentTintColor
//            if let image = self.image,
//               let color = self.contentTintColor {
//                self.image = image.tint(color: color)
//            }
        }
    }

    override open var intrinsicContentSize: CGSize {
        self.systemButton.intrinsicContentSize
    }

    override public var isEnabled: Bool {
        get { self.systemButton.isEnabled }
        set { self.systemButton.isEnabled = newValue }
    }

    public var intValue: Int32 {
        get { self.systemButton.intValue }
        set { self.systemButton.intValue = newValue }
    }
}
