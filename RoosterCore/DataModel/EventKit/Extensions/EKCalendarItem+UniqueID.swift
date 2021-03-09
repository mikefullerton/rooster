//
//  EKCalendarItem+UniqueID.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/23/21.
//

import Foundation
import EventKit

extension EKCalendarItem {
    
    public func uniqueID(forStartDate startDate: Date) -> String {
        
        let components = NSCalendar.current.dateComponents([.year, .day, .month], from: startDate)
        
        
        let id = """
        \(self.calendar.uniqueID)+\
        \(self.calendarItemExternalIdentifier ?? self.calendarItemIdentifier)+\
        \(components.month!)-\(components.day!)-\(components.year!)
        """
        
        return id
        
    }
}
