//
//  Date+Utilities.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/16/20.
//

import Foundation


extension Date {

    func isEquaToOrAfterDate(_ date: Date) -> Bool {
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
    
    var shortDateString: String {
        return DateFormatter.localizedString(from: self, dateStyle: .none, timeStyle: .short)
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
}

extension DateComponents {
    var date: Date? {
        return NSCalendar.current.date(from: self)
    }
}

