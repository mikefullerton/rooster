//
//  Date+Utilities.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/16/20.
//

import Foundation


extension Date {
    
    func isAfterDate(_ date: Date) -> Bool {
        let isAfter = self.compare(date) == .orderedDescending
        return isAfter
    }
    
    func isBeforeDate(_ date: Date) -> Bool {
        let isBefore = self.compare(date) == .orderedAscending
        return isBefore
    }
    
    var asShortDateString: String {
        return DateFormatter.localizedString(from: self, dateStyle: .none, timeStyle: .short)
    }
    
}

extension DateComponents {
    var date: Date? {
        return NSCalendar.current.date(from: self)
    }
}
