//
//  NSImage+Utilities.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/24/21.
//

import Foundation
import Cocoa

extension NSImage {
    func tint(color: NSColor) -> NSImage {
        let image = self.copy() as! NSImage
        image.lockFocus()

        color.set()

        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceIn) // .sourceAtop

        image.unlockFocus()
        image.size = self.size
        
        return image
    }
}

//private func systemImage(named systemImageName: String, tint: SDKColor?) -> SDKImage? {
//    if let image = SDKImage(systemSymbolName: systemImageName, accessibilityDescription: self.toolTip),
//       let symbol = image.withSymbolConfiguration(SDKImage.SymbolConfiguration(pointSize: 18, weight: .medium)) {
//    
//        if tint != nil {
//            return symbol.tint(color: tint!)
//        }
//        
//        return symbol
//    }
//    
//    return nil
//}
