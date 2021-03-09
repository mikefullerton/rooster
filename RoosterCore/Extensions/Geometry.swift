//
//  Geometry.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/20/21.
//

import Foundation

// swiftlint:disable identifier_name file_types_order

public func RadiansFromDegrees(_ degrees: Double) -> Double {
    (degrees * .pi) / 180.0
}

public func DegreesFromRadians(_ radians: Double) -> Double {
    radians * 180.0 / .pi
}

// swiftlint:enable identifier_name

extension SDKEdgeInsets {
    public static let ten = SDKEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    public static let twenty = SDKEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
}

extension CGSize {
    public static let ten = CGSize(width: 10, height: 10)
    public static let twenty = CGSize(width: 20, height: 20)
}

extension CGSize: AdditiveArithmetic {
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
        lhs.width > rhs.width ? lhs : rhs
    }

    public static func minWidth(lhs: CGSize, rhs: CGSize) -> CGSize {
        lhs.width < rhs.width ? lhs : rhs
    }

    public static func maxHeight(lhs: CGSize, rhs: CGSize) -> CGSize {
        lhs.height > rhs.height ? lhs : rhs
    }

    public static func minHeight(lhs: CGSize, rhs: CGSize) -> CGSize {
        lhs.height < rhs.height ? lhs : rhs
    }
}

extension SDKOffset {
    public static let ten = SDKOffset(horizontal: 10, vertical: 10)
    public static let twenty = SDKOffset(horizontal: 20, vertical: 20)
}

extension CGRect {
    public func centered(in containingRect: CGRect) -> CGRect {
        var toCenter = self
        toCenter.center(in: containingRect)
        return toCenter
    }

    public mutating func center(in containingRect: CGRect) {
        self.origin.x = containingRect.origin.x + (containingRect.size.width / 2.0) - (self.size.width / 2.0)
        self.origin.y = containingRect.origin.y + (containingRect.size.height / 2.0) - (self.size.height / 2.0)
    }

//    public mutating func centerFlipped(in containingRect: CGRect) {
//        self.origin.x = containingRect.maxX - (containingRect.size.width / 2.0)
//        self.origin.y = containingRect.origin.y - (containingRect.size.height / 2.0) - (self.size.height / 2.0)
//    }

}

// this is just here to shut the linter up about the file_name
private enum Geometry {
}
