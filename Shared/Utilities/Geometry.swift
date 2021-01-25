//
//  Geometry.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/20/21.
//

import Foundation

extension SDKEdgeInsets {
    static var ten: SDKEdgeInsets { return SDKEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) }
    static var twenty: SDKEdgeInsets { return SDKEdgeInsets(top: 20, left: 20, bottom: 20, right: 20) }
}

extension CGSize {
    static var ten: CGSize { return CGSize(width: 10, height: 10) }
}

extension CGRect {
//    static var zero: CGRect { return NSZeroRect }
}

extension CGPoint {
//    static var zero: CGPoint { return NSZeroPoint }
}

extension SDKOffset {
    static var ten: SDKOffset = SDKOffset(horizontal: 10, vertical: 10)
    static var twenty: SDKOffset = SDKOffset(horizontal: 20, vertical: 20)
}
