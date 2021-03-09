//
//  Date+Utilities.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/16/20.
//

import Foundation


extension Date {

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
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    public var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    public var isTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    
    public var shortTimeString: String {
        return DateFormatter.localizedString(from: self, dateStyle: .none, timeStyle: .short)
    }
    
    public var shortDateAndTimeString: String {
        return DateFormatter.localizedString(from: self, dateStyle: .short, timeStyle: .short)
    }
    
    public var shortDateAndLongTimeString: String {
        return DateFormatter.localizedString(from: self, dateStyle: .short, timeStyle: .long)
    }

    public func addDays(_ days: Int) -> Date {
        let currentCalendar = NSCalendar.current
        
        let dateComponents = currentCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .timeZone], from: self)
        
        let components = currentCalendar.date(from: dateComponents)!
        let newDate: Date = currentCalendar.date(byAdding: .day, value: days, to: components)!
            
        return newDate
    }
    
    public func addHours(_ hours: Int) -> Date {
        return self.addingTimeInterval( Date.interval(fromHours: hours))
            
    }

    public func addMinutes(_ minutes: Int) -> Date {
        return self.addingTimeInterval( Date.interval(fromMinutes: minutes))
    }

    public func addSeconds(_ seconds: Int) -> Date {
        return self.addingTimeInterval( TimeInterval( seconds))
    }

    public var removeSeconds: Date {
        let calendar = NSCalendar.current
        let dateComponents = calendar.dateComponents([.era , .year , .month , .day , .hour , .minute, .timeZone], from: self)
        if let date = calendar.date(from: dateComponents) {
            return date
        }
        return self
    }

    public var removeMinutesAndSeconds: Date {
        let calendar = NSCalendar.current
        let dateComponents = calendar.dateComponents([.era , .year , .month , .day , .hour, .timeZone], from: self)
        if let date = calendar.date(from: dateComponents) {
            return date
        }
        return self
    }
    
    public var removingTime: Date {
        let calendar = NSCalendar.current
        let dateComponents = calendar.dateComponents([.era , .year , .month, .timeZone], from: self)
        if let date = calendar.date(from: dateComponents) {
            return date
        }
        return self
    }

    public static var midnightToday: Date {
        let calendar = NSCalendar.current
        let dateComponents = calendar.dateComponents([.era , .year , .month , .day, .timeZone], from: Date())
        let date = calendar.date(from: dateComponents)!
        return date
    }
    
    public static var midnightYesterday: Date {
        return self.midnightToday.addDays(-1)
    }
    
    public var components: DateComponents {
        return NSCalendar.current.dateComponents([.era, .timeZone, .year, .month, .day, .hour, .minute, .second], from: self)
    }
    
    public static func secondsToInterval(_ seconds: Int) -> TimeInterval {
        return TimeInterval(seconds)
    }

    public static func minutesToInterval(_ minutes: Int) -> TimeInterval {
        return Self.secondsToInterval(60) * TimeInterval(minutes)
    }

    public static func hoursToInterval(_ hours: Int) -> TimeInterval {
        return Self.minutesToInterval(60) * TimeInterval(hours)
    }

    public static func daysToInterval(_ days: Int) -> TimeInterval {
        return Self.hoursToInterval(24) * TimeInterval(days)
    }

    public static func hours(fromInterval interval: TimeInterval) -> Int {
        let hours = interval / (60 * 60)
        return max(0, Int(hours))
    }

    public static func minutes(fromInterval interval: TimeInterval) -> Int {
        let minutes = interval / (60)
        return max(0, Int(minutes))
    }
    
    public static func interval(fromHours hours: Int) -> TimeInterval {
        return TimeInterval(hours) * 60 * 60
    }

    public static func interval(fromMinutes minutes: Int) -> TimeInterval {
        return TimeInterval(minutes) * 60
    }

    public func interval(toFutureDate futureDate: Date) -> TimeInterval {
        let myTime = self.timeIntervalSinceReferenceDate
        let futureTime = futureDate.timeIntervalSinceReferenceDate
        let difference = futureTime - myTime
        return max(0, difference)
    }
    
    public func difference(fromDate otherDate: Date) -> TimeInterval {
        let myTime = self.timeIntervalSinceReferenceDate
        let otherTime = otherDate.timeIntervalSinceReferenceDate
        
        let maxTime = max(myTime, otherTime)
        let minTime = min(myTime, otherTime)
        
        return maxTime - minTime
    }

    public static func later(_ lhs: Date, _ rhs: Date) -> Date {
        return lhs.isAfterDate(rhs) ? lhs : rhs
    }

    public static func earlier (_ lhs: Date, _ rhs: Date) -> Date {
        return lhs.isBeforeDate(rhs) ? lhs : rhs
    }
    
    public func isWithinRange(starting: Date, ending: Date) -> Bool {
        return starting.isEqualToOrBeforeDate(self) && ending.isEqualToOrAfterDate(self)
    }
    
    public static func daysBetween(lhs: Date, rhs: Date) -> Int? {
        let calendar = Calendar.current

        let date1 = calendar.startOfDay(for:lhs)
        let date2 = calendar.startOfDay(for:rhs)

        let components = calendar.dateComponents([.day], from: date1, to: date2)
//                                             fr: date1, toDate: date2, options: [])
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

//    public static func daysBetween(lhs: Date, rhs: Date) -> Int? {
//
//        var fromDate:NSDate?
//        var toDate:NSDate?
//
//        let calendar = Calendar.current
//
//        calendar.range(of: .day, start: &fromDate, interval: nil, for: lhs)
//        calendar.range(of: .day, start: &toDate, interval: nil, for: rhs)
//
////        calendar.rangeOfUnit(NSCalendarUnit.DayCalendarUnit, startDate: &toDate, interval: nil, forDate: toDateTime)
////
////        if let from = fromDate {
////
////            if let to = toDate {
////
////                let difference = calendar.components(NSCalendarUnit.DayCalendarUnit, fromDate: from, toDate: to, options: NSCalendarOptions.allZeros)
////
////                return difference.day
////            }
////        }
//
//        return nil
//    }
}

public extension DateComponents {
    var date: Date? {
        return NSCalendar.current.date(from: self)
    }
}

