//
//  Geometry.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/20/21.
//

import Foundation

extension SDKEdgeInsets {
    public static let ten = SDKEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    public static let twenty = SDKEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
}

extension CGSize {
    public static let ten = CGSize(width: 10, height: 10)
    public static let twenty = CGSize(width: 20, height: 20)
}
    
extension CGSize : AdditiveArithmetic {
    public static func + (lhs: Self, rhs: Self) -> Self {
        var size = lhs
        size += rhs
        return size
    }

    public static func += (lhs: inout Self, rhs: Self) {
        lhs.width += rhs.width
        lhs.height += rhs.height
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        var size = lhs
        size -= rhs
        return size
    }

    public static func -= (lhs: inout Self, rhs: Self) {
        lhs.width -= rhs.width
        lhs.height -= rhs.height
    }

    public static func + (lhs: Self, amount: CGFloat) -> Self {
        var size = lhs
        size.width += amount
        size.height += amount
        return size
    }

    public static func += (lhs: inout Self, amount: CGFloat) {
        lhs.width += amount
        lhs.height += amount
    }

    public static func - (lhs: Self, amount: CGFloat) -> Self {
        var size = lhs
        size -= amount
        return size
    }

    public static func -= (lhs: inout Self, amount: CGFloat) {
        lhs.width -= amount
        lhs.height -= amount
    }
}

extension CGSize {
    public static func * (lhs: Self, rhs: Self) -> Self {
        var size = lhs
        size *= rhs
        return size
    }

    public static func *= (lhs: inout Self, rhs: Self) {
        lhs.width *= rhs.width
        lhs.height *= rhs.height
    }

    public static func / (lhs: Self, rhs: Self) -> Self {
        var size = lhs
        size /= rhs
        return size
    }

    public static func /= (lhs: inout Self, rhs: Self) {
        lhs.width /= rhs.width
        lhs.height /= rhs.height
    }

    public static func * (lhs: Self, amount: CGFloat) -> Self {
        var size = lhs
        size.width *= amount
        size.height *= amount
        return size
    }

    public static func *= (lhs: inout Self, amount: CGFloat) {
        lhs.width *= amount
        lhs.height *= amount
    }

    public static func / (lhs: Self, amount: CGFloat) -> Self {
        var size = lhs
        size /= amount
        return size
    }

    public static func /= (lhs: inout Self, amount: CGFloat) {
        lhs.width /= amount
        lhs.height /= amount
    }

}

extension CGSize {
    
    public static func maxWidth(lhs: CGSize, rhs: CGSize) -> CGSize {
        return lhs.width > rhs.width ? lhs : rhs
    }
    
    public static func minWidth(lhs: CGSize, rhs: CGSize) -> CGSize {
        return lhs.width < rhs.width ? lhs : rhs
    }
    
    public static func maxHeight(lhs: CGSize, rhs: CGSize) -> CGSize {
        return lhs.height > rhs.height ? lhs : rhs
    }
    
    public static func minHeight(lhs: CGSize, rhs: CGSize) -> CGSize {
        return lhs.height < rhs.height ? lhs : rhs
    }
}

public extension SDKOffset {
    static let ten = SDKOffset(horizontal: 10, vertical: 10)
    static let twenty = SDKOffset(horizontal: 20, vertical: 20)
}


