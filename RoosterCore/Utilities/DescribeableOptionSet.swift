//
//  DescribeableOptionSet.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/16/21.
//

import Foundation

public protocol DescribeableOptionSet: OptionSet, CustomStringConvertible, AdditiveArithmetic, Codable, Sequence {
    static var descriptions: [(Self.Element, String)] { get }
}

// swiftlint:disable force_cast

extension DescribeableOptionSet {
    public var description: String {
        let filteredResults = Self.descriptions.filter {
            self.contains($0.0)
        }

        let results: [String] = filteredResults.map {
            ".\($0.1)"
        }

        return "[\(results.joined(separator: ", "))] (\(rawValue)) "
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        var state = lhs
        state.insert(rhs as! Self.Element)
        return state
    }

    public static func += (lhs: inout Self, rhs: Self) {
        lhs.insert(rhs as! Self.Element)
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        var state = lhs
        state.remove(rhs as! Self.Element)
        return state
    }

    public static func -= (lhs: inout Self, rhs: Self) {
        lhs.remove(rhs as! Self.Element)
    }

    public mutating func set(_ value: Self.Element, to inOrOut: Bool) {
        if inOrOut {
            self.insert(value)
        } else {
            self.remove(value)
        }
    }
}

extension DescribeableOptionSet where Self.RawValue == Int {
    public func makeIterator() -> OptionSetIterator<Self> {
        OptionSetIterator(element: self)
    }
}

// swiftlint:enable force_cast
