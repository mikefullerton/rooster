//
//  MacViews.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/24/21.
//

import Foundation
import Cocoa

// geometry
public typealias SDKEdgeInsets = NSEdgeInsets

public struct SDKOffset {
    public var horizontal: CGFloat = 0
    public var vertical: CGFloat = 0

    public init(horizontal: CGFloat, vertical: CGFloat) {
        self.horizontal = horizontal
        self.vertical = vertical
    }
    
    public static let zero = SDKOffset(horizontal: 0, vertical: 0)
}

// classes

public typealias SDKColor = NSColor
public typealias SDKFont = NSFont


