//
//  Calender.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation

public struct RCDemoCalendar: Identifiable, CustomStringConvertible, Equatable, Hashable, EventKitCalendar {
    public let title: String
    public let id: String
    public let ekCalendarID: String
    public let sourceTitle: String
    public let sourceIdentifier: String
    public let cgColor: CGColor?

    // modifiable
    public var isSubscribed: Bool

    public init(withIdentifier identifier: String,
                ekCalendarID: String,
                title: String,
                sourceTitle: String,
                sourceIdentifier: String,
                isSubscribed: Bool,
                color: CGColor?) {
        self.id = identifier
        self.ekCalendarID = ekCalendarID
        self.title = title
        self.sourceTitle = sourceTitle
        self.sourceIdentifier = sourceIdentifier
        self.isSubscribed = isSubscribed
        self.cgColor = color
    }

    public var description: String {
        "\(type(of: self)): \(self.sourceTitle): \(self.title), isSubscribed: \(self.isSubscribed)"
    }

    public static func == (lhs: RCDemoCalendar, rhs: RCDemoCalendar) -> Bool {
        lhs.id == rhs.id &&
                lhs.title == rhs.title &&
                lhs.isSubscribed == rhs.isSubscribed &&
                lhs.sourceTitle == rhs.sourceTitle &&
                lhs.sourceIdentifier == rhs.sourceIdentifier
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
