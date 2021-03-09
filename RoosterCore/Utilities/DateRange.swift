//
//  DateRange.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/28/21.
//

import Foundation

public struct DateRange: Codable, Equatable, CustomStringConvertible {
    // MARK: - properties

    public var startDate: Date

    public static let invalid = DateRange()

    public var endDate: Date {
        didSet {
            assert(self.endDate.isAfterDate(self.startDate), "endDate is before startDate")
        }
    }

    public var length: TimeInterval {
        get {
            self.endDate.difference(fromDate: self.startDate)
        }
        set {
            if newValue != self.length && newValue > 0 {
                self.endDate = self.startDate.addingTimeInterval(newValue)
            }
        }
    }

    public var lengthInMinutes: Int {
        Date.minutes(fromInterval: self.length)
    }

    public var isHappeningNow: Bool {
        let now = Date()
        return self.startDate.isEqualToOrBeforeDate(now) && self.endDate.isEqualToOrAfterDate(now)
    }

    public var isInThePast: Bool {
        self.endDate.isBeforeDate(Date())
    }

    public var isInTheFuture: Bool {
        self.startDate.isAfterDate(Date())
    }

    public var isMultiDay: Bool {
        self.dayCount > 1
    }

    public var dayCount: Int {
        Date.daysBetween(lhs: self.startDate, rhs: self.endDate) ?? 0
    }

    public var isAllDay: Bool {
        self.dayCount == 0 &&
        (self.startDate == self.startDate.startOfDay || self.startDate == self.startDate.midnight) &&
        self.endDate == self.endDate.endOfDay
    }

    public init(startDate: Date,
                dayCount: Int) {
        assert(dayCount > 0, "invalid day count")
        let endDate = startDate.addDays(dayCount).addSeconds(-1)
        assert(endDate.isAfterDate(startDate), "endDate is before startDate")

        self.startDate = startDate
        self.endDate = endDate
    }

    public init(startDate: Date,
                endDate: Date) {
        assert(endDate.isAfterDate(startDate), "endDate is before startDate")
        self.startDate = startDate
        self.endDate = endDate
    }

    public init(startDate: Date,
                length: TimeInterval) {
        assert(length > 0, "invalid length")
        self.startDate = startDate
        self.endDate = startDate.addingTimeInterval(length)
    }

    public init(startDate: Date,
                lengthInMinutes: Int) {
        assert(lengthInMinutes > 0, "invalid length")
        self.startDate = startDate
        self.endDate = startDate.addMinutes(lengthInMinutes)
    }

    private init() {
        self.startDate = Date.distantPast
        self.endDate = Date.distantPast
    }

    public var dayRanges: [DateRange] {
        let dayCount = self.dayCount

        guard dayCount > 0 else {
            return [self]
        }

        var days: [DateRange] = []
        days.append(DateRange(startDate: self.startDate, endDate: self.startDate.endOfDay))

        if dayCount > 2 {
            var nextDay = self.startDate.midnight.addDays(1)
            for _ in 0..<dayCount - 2 {
                days.append(DateRange(startDate: nextDay, endDate: nextDay.endOfDay))
                nextDay = nextDay.addDays(1)
            }
        }

        if !self.endDate.isMidnight {
            days.append(DateRange(startDate: self.endDate.startOfDay, endDate: self.endDate))
        }

        return days
    }

    public var description: String {
        """
        \(type(of: self)): \
        Start Date: \(self.startDate.shortDateAndLongTimeString), \
        End Date: \(self.endDate.shortDateAndLongTimeString), \
        length: \(self.length), \
        lengthInMinutes: \(self.lengthInMinutes)
        """
    }

    public func contains(_ date: Date?) -> Bool {
        guard let date = date else {
            return false
        }

        return date.isEqualToOrAfterDate(self.startDate) && date.isEqualToOrBeforeDate(self.endDate)
    }
}
