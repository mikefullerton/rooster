//
//  Geometry.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/20/21.
//

import Foundation
import Cocoa

extension NSEdgeInsets {
    static var zero: NSEdgeInsets { return NSEdgeInsetsZero }
    static var ten: NSEdgeInsets { return NSEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) }
    static var twenty: NSEdgeInsets { return NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20) }
}

extension CGSize {
    static var zero: CGSize { return NSZeroSize }
}

extension CGRect {
    static var zero: CGRect { return NSZeroRect }
}

extension CGPoint {
    static var zero: CGPoint { return NSZeroPoint }
}


