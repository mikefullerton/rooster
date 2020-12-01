//
//  DataModel+EventUtilities.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation

extension DataModel {
    
    var nextEventTime: Date? {
        
        let now = Date()
        
        for event in self.events {
            if event.startDate.isAfterDate(now) {
                return event.startDate
            }

            if event.startDate.isAfterDate(now) {
                return event.endDate
            }
        }
        
        let currentCalendar = NSCalendar.current
        
        let dateComponents = currentCalendar.dateComponents([.year, .month, .day], from: Date())
        
        if let today = currentCalendar.date(from: dateComponents),
           let tomorrow: Date = currentCalendar.date(byAdding: .day, value: 1, to: today) {
            
            return tomorrow
        }
        
        return nil
    }
    
    var nextEventStartTime: Date? {
        let now = Date()
        
        for event in self.events {
            if event.startDate.isAfterDate(now) {
                return event.startDate
            }
        }
        
        return nil
    }
}
