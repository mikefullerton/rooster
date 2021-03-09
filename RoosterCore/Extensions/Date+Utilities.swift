//
//  Date+Utilities.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/16/20.
//

import Foundation

extension Date {
    public var startOfDay: Date {
        Foundation.Calendar.current.startOfDay(for: self)
    }

    public var endOfDay: Date {
        self.midnight.addDays(1).addSeconds(-1)
    }

    public static var startOfToday: Date {
        Date().startOfDay
    }
    public static var endOfToday: Date {
        Date().endOfDay
    }
}

extension Date {
    public var midnight: Date {
        let calendar = Foundation.Calendar.current
        let dateComponents = calendar.dateComponents([.era, .year, .month, .day, .timeZone], from: self)
        let date = calendar.date(from: dateComponents)!
        return date
    }

    public static var midnightToday: Date {
        let calendar = Foundation.Calendar.current
        let dateComponents = calendar.dateComponents([.era, .year, .month, .day, .timeZone], from: Date())
        let date = calendar.date(from: dateComponents)!
        return date
    }

    public static var midnightYesterday: Date {
        self.midnightToday.addDays(-1)
    }

    public static var midnightTomorrow: Date {
        self.midnightToday.addDays(-1)
    }
}

extension Date {
    // MARK: manipulating

    public func addDays(_ days: Int) -> Date {
        let currentCalendar = Foundation.Calendar.current

        let dateComponents = currentCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .timeZone], from: self)

        let components = currentCalendar.date(from: dateComponents)!
        let newDate: Date = currentCalendar.date(byAdding: .day, value: days, to: components)!

        return newDate
    }

    public func addHours(_ hours: Int) -> Date {
        self.addingTimeInterval( Date.interval(fromHours: hours))
    }

    public func addMinutes(_ minutes: Int) -> Date {
        self.addingTimeInterval( Date.interval(fromMinutes: minutes))
    }

    public func addSeconds(_ seconds: Int) -> Date {
        self.addingTimeInterval( TimeInterval( seconds))
    }

    public var removeSeconds: Date {
        let calendar = Foundation.Calendar.current
        let dateComponents = calendar.dateComponents([.era, .year, .month, .day, .hour, .minute, .timeZone], from: self)
        if let date = calendar.date(from: dateComponents) {
            return date
        }
        return self
    }

    public var removeMinutesAndSeconds: Date {
        let calendar = Foundation.Calendar.current
        let dateComponents = calendar.dateComponents([.era, .year, .month, .day, .hour, .timeZone], from: self)
        if let date = calendar.date(from: dateComponents) {
            return date
        }
        return self
    }
}

extension Date {
    // MARK: - intervals

    public static func interval(fromSeconds seconds: Int) -> TimeInterval {
        TimeInterval(seconds)
    }

    public static func interval(fromMinutes minutes: Int) -> TimeInterval {
        Self.interval(fromSeconds: 60) * TimeInterval(minutes)
    }

    public static func interval(fromHours hours: Int) -> TimeInterval {
        Self.interval(fromMinutes: 60) * TimeInterval(hours)
    }

    public static func interval(fromDays days: Int) -> TimeInterval {
        Self.interval(fromHours: 24) * TimeInterval(days)
    }

    public static func seconds(fromInterval interval: TimeInterval) -> Int {
        max(0, Int(interval))
    }

    public static func minutes(fromInterval interval: TimeInterval) -> Int {
        max(0, Int(interval / (60)))
    }

    public static func hours(fromInterval interval: TimeInterval) -> Int {
        max(0, Int(interval / (60 * 60)))
    }

    public static func days(fromInterval interval: TimeInterval) -> Int {
        max(0, Int(interval / (60 * 60 * 24)))
    }

    public func interval(toFutureDate futureDate: Date) -> TimeInterval {
        let myTime = self.timeIntervalSinceReferenceDate
        let futureTime = futureDate.timeIntervalSinceReferenceDate
        let difference = futureTime - myTime
        return max(0, difference)
    }
}

extension Date {
    // MARK: - strings

    public var shortTimeString: String {
        DateFormatter.localizedString(from: self, dateStyle: .none, timeStyle: .short)
    }

    public var shortDateAndTimeString: String {
        DateFormatter.localizedString(from: self, dateStyle: .short, timeStyle: .short)
    }

    public var shortDateAndLongTimeString: String {
        DateFormatter.localizedString(from: self, dateStyle: .short, timeStyle: .long)
    }

    public var shortDateString: String {
        DateFormatter.localizedString(from: self, dateStyle: .short, timeStyle: .none)
    }

    public var longDateString: String {
        DateFormatter.localizedString(from: self, dateStyle: .full, timeStyle: .none)
    }

    public var niceDateString: String {
        if self.isToday {
            return "Today"
        } else if self.isTomorrow {
            return "Tomorrow"
        }

        return self.longDateString
    }
}

extension Date {
    // MARK: - comparisons

    public func isEqualToOrAfterDate(_ date: Date) -> Bool {
        let isAfter = self.compare(date) != .orderedAscending
        return isAfter
    }

    public func isAfterDate(_ date: Date) -> Bool {
        let isAfter = self.compare(date) == .orderedDescending
        return isAfter
    }

    public func isEqualToOrBeforeDate(_ date: Date) -> Bool {
        let isBefore = self.compare(date) != .orderedDescending
        return isBefore
    }

    public func isBeforeDate(_ date: Date) -> Bool {
        let isBefore = self.compare(date) == .orderedAscending
        return isBefore
    }

    public func isSameDay(asDate date: Date) -> Bool {
        Foundation.Calendar.current.isDate(self, inSameDayAs: date)
    }

    public var isToday: Bool {
        Foundation.Calendar.current.isDateInToday(self)
    }

    public var isTomorrow: Bool {
        Foundation.Calendar.current.isDateInTomorrow(self)
    }

    public func isWithinRange(starting: Date, ending: Date) -> Bool {
        starting.isEqualToOrBeforeDate(self) && ending.isEqualToOrAfterDate(self)
    }

    public var isMidnight: Bool {
        let isMidnight = self.compare(self.midnight) == .orderedSame
        return isMidnight
//
//
//        let calendar = Foundation.Calendar.current
//        let dateComponents = calendar.dateComponents([.hour, .minute, .second, .timeZone], from: Date())
//
//        guard dateComponents.minute == 0, dateComponents.second == 0 else {
//            return false
//        }
//
//        return true
    }

    public func difference(fromDate otherDate: Date) -> TimeInterval {
        let myTime = self.timeIntervalSinceReferenceDate
        let otherTime = otherDate.timeIntervalSinceReferenceDate

        let maxTime = max(myTime, otherTime)
        let minTime = min(myTime, otherTime)

        return maxTime - minTime
    }

    public static func later(_ lhs: Date, _ rhs: Date) -> Date {
        lhs.isAfterDate(rhs) ? lhs : rhs
    }

    public static func earlier (_ lhs: Date, _ rhs: Date) -> Date {
        lhs.isBeforeDate(rhs) ? lhs : rhs
    }

    public static func daysBetween(lhs: Date, rhs: Date) -> Int? {
        let calendar = Foundation.Calendar.current

        let date1 = calendar.startOfDay(for: lhs)
        let date2 = calendar.startOfDay(for: rhs)

        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day
    }

    public static func range(_ range: ClosedRange<Date>, intersectsRange enclosingRange: ClosedRange<Date>) -> Bool {
        if range.lowerBound.isWithinRange(starting: enclosingRange.lowerBound, ending: enclosingRange.upperBound) {
            return true
        }

        if range.upperBound.isWithinRange(starting: enclosingRange.lowerBound, ending: enclosingRange.upperBound) {
            return true
        }

        return false
    }
}

extension Date {
    public var components: DateComponents {
        Foundation.Calendar.current.dateComponents([.era, .timeZone, .year, .month, .day, .hour, .minute, .second], from: self)
    }
}

extension DateComponents {
    public var date: Date? {
        Foundation.Calendar.current.date(from: self)
    }
}
