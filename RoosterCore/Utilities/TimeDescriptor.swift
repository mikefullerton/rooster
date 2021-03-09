//
//  TimeDescriptor.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/3/21.
//

import Foundation

// 24 hour clock
public struct TimeDescriptor: Codable, Equatable, CustomStringConvertible {
    public var hour24: Int

    public var hour12: Int {
        isPM ? hour24 - 12 : hour24
    }

    public var minute: Int

    public var isPM: Bool {
        hour24 > 12
    }

    public var amPM: String {
        isPM ? "PM" : "AM"
    }

    public var description: String {
        """
        \(type(of: self)): \
        \(hour12):\(minute) \(amPM)
        """
    }

    public init(hour: Int) {
        self.hour24 = hour
        self.minute = 0
    }

    public init(hour: Int, minute: Int) {
        self.hour24 = hour
        self.minute = minute
    }

    public var date: Date {
        var date = Date.midnightToday
        date = date.addHours(self.hour24)
        date = date.addMinutes(self.minute)
        return date
    }
}
