//
//  HighlightableTextField.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/11/21.
//

import AppKit
import Foundation

public class HighlightableTextField: NSTextField {
    public var originalColor: NSColor?

    override public var textColor: NSColor? {
        get { super.textColor }
        set {
            super.textColor = newValue
            self.originalColor = newValue
        }
    }

    private func updateTextColor() {
        if self.isEnabled {
            super.textColor = self.isHighlighted ? Theme(for: self).userChosenHighlightColor : self.originalColor
        } else {
            super.textColor = NSColor.disabledControlTextColor
        }
    }

    override public var isHighlighted: Bool {
        didSet {
            if self.isHighlighted != oldValue {
                self.updateTextColor()
            }
        }
    }

    override public var isEnabled: Bool {
        didSet {
            if self.isEnabled != oldValue {
                self.updateTextColor()
            }
        }
    }
}
