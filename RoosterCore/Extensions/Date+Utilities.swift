//
//  Date+Utilities.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/16/20.
//

import Foundation


public extension Date {

    func isEqualToOrAfterDate(_ date: Date) -> Bool {
        let isAfter = self.compare(date) != .orderedAscending
        return isAfter
    }

    func isAfterDate(_ date: Date) -> Bool {
        let isAfter = self.compare(date) == .orderedDescending
        return isAfter
    }
    
    func isEqualToOrBeforeDate(_ date: Date) -> Bool {
        let isBefore = self.compare(date) != .orderedDescending
        return isBefore
    }
    
    func isBeforeDate(_ date: Date) -> Bool {
        let isBefore = self.compare(date) == .orderedAscending
        return isBefore
    }
    
    var shortTimeString: String {
        return DateFormatter.localizedString(from: self, dateStyle: .none, timeStyle: .short)
    }
    
    var shortDateAndTimeString: String {
        return DateFormatter.localizedString(from: self, dateStyle: .short, timeStyle: .short)
    }
    
    var shortDateAndLongTimeString: String {
        return DateFormatter.localizedString(from: self, dateStyle: .short, timeStyle: .long)
    }

    func byAddingDays(_ days: Int) -> Date {
        let currentCalendar = NSCalendar.current
        
        let dateComponents = currentCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        
        let components = currentCalendar.date(from: dateComponents)!
        let newDate: Date = currentCalendar.date(byAdding: .day, value: days, to: components)!
            
        return newDate
    }
        
    var dateWithoutSeconds: Date {
        let calendar = NSCalendar.current
        let dateComponents = calendar.dateComponents([.era , .year , .month , .day , .hour , .minute], from: self)
        if let date = calendar.date(from: dateComponents) {
            return date
        }
        return self
    }
    
    
    static var midnightToday: Date {
        let calendar = NSCalendar.current
        let dateComponents = calendar.dateComponents([.era , .year , .month , .day], from: Date())
        let date = calendar.date(from: dateComponents)!
        return date
    }
    
    static var midnightYesterday: Date {
        return self.midnightToday.byAddingDays(-1)
    }
}

public extension DateComponents {
    var date: Date? {
        return NSCalendar.current.date(from: self)
    }
}

