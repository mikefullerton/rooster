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

    var tomorrow: Date? {
        let currentCalendar = NSCalendar.current
        
        let dateComponents = currentCalendar.dateComponents([.year, .month, .day], from: Date())
        
        if let today = currentCalendar.date(from: dateComponents),
           let tomorrow: Date = currentCalendar.date(byAdding: .day, value: 1, to: today) {
            
            return tomorrow
        }
        
        return nil
    }
    
    var dateWithoutSeconds: Date {
        let calendar = NSCalendar.current
        let dateComponents = calendar.dateComponents([.era , .year , .month , .day , .hour , .minute], from: self)
        if let date = calendar.date(from: dateComponents) {
            return date
        }
        return self
    }
}

public extension DateComponents {
    var date: Date? {
        return NSCalendar.current.date(from: self)
    }
}

