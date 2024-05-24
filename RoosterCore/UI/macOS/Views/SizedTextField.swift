//
//  SizeTextField.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 4/22/21.
//

import Cocoa
import Foundation
import AppKit

open class SizedTextField: NSTextField {
    public var preferredSize = CGSize.noIntrinsicMetric

    override open var intrinsicContentSize: NSSize {
        var size = super.intrinsicContentSize

        if self.preferredSize.width != NSView.noIntrinsicMetric {
            size.width = self.preferredSize.width
        }

        if self.preferredSize.height != NSView.noIntrinsicMetric {
            size.height = self.preferredSize.height
        }

        return size
    }
}
