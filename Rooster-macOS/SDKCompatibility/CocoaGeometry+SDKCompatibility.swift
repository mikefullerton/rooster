//
//  Geometry.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/24/21.
//

import Foundation
import RoosterCore
import Cocoa

extension CGSize {
    static var zero: CGSize { return NSZeroSize }
}

extension CGRect {
    static var zero: CGRect { return NSZeroRect }
}

extension CGPoint {
    static var zero: CGPoint { return NSZeroPoint }
}

extension NSEdgeInsets {
    static var zero: SDKEdgeInsets { return NSEdgeInsetsZero }
}

extension SDKOffset {
    static var zero: SDKOffset = SDKOffset(horizontal: 0, vertical: 0)
}
