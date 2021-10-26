//
//  CalendarReference.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/29/21.
//

import Foundation

public struct CalendarReference: Equatable, Hashable, Comparable, Identifiable, CustomStringConvertible {
    public typealias ID = String

    public var id: String {
        self.calendar.id
    }

    public let calendar: Calendar

    public var fullyQualifiedTitle: String {
        "\(self.calendar.source.title).\(self.calendar.title)"
    }

    public init(_ calendar: Calendar) {
        self.calendar = calendar
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.fullyQualifiedTitle)
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.fullyQualifiedTitle < rhs.fullyQualifiedTitle
    }

    public static func <= (lhs: Self, rhs: Self) -> Bool {
        lhs.fullyQualifiedTitle <= rhs.fullyQualifiedTitle
    }

    public static func >= (lhs: Self, rhs: Self) -> Bool {
        lhs.fullyQualifiedTitle >= rhs.fullyQualifiedTitle
    }

    public static func > (lhs: Self, rhs: Self) -> Bool {
        lhs.fullyQualifiedTitle > rhs.fullyQualifiedTitle
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.calendar.isEqual(to: rhs.calendar)
    }

    public var description: String {
        """
        \(type(of: self)): \
        calendar: \(self.calendar.description)
        """
    }
}
