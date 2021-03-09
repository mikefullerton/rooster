//
//  NSImage+Utilities.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/24/21.
//

import Cocoa
import Foundation

extension NSImage {
    public func tint(color: NSColor) -> NSImage {
        NSImage(size: size, flipped: false) { rect -> Bool in
            color.set()
            rect.fill()
            self.draw(in: rect, from: NSRect(origin: .zero, size: self.size), operation: .destinationIn, fraction: 1.0)
            return true
        }
    }

    public static func image(withSystemSymbolName systemSymbolName: String,
                             accessibilityDescription: String?,
                             symbolConfiguration: NSImage.SymbolConfiguration? = nil ) -> NSImage? {
        var image = NSImage(systemSymbolName: systemSymbolName, accessibilityDescription: accessibilityDescription)
        if image != nil && symbolConfiguration != nil {
            image = image!.withSymbolConfiguration(symbolConfiguration!)
        }

        return image
    }

    public static func transparentImage(ofSize size: CGSize) -> NSImage {
        NSImage(size: size, flipped: false) { rect -> Bool in
            NSColor.clear.set()
            rect.fill()
//            self.draw(in: rect,
//                      from: NSRect(origin: .zero, size: self.size),
//                      operation: .destinationIn,
//                      fraction: 1.0)
            return true
        }
    }
}
