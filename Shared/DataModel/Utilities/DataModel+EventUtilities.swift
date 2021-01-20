//
//  DataModel+EventUtilities.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation

extension DataModel {
    
    private func nextAlarmDate(forItems items: [CalendarItem]) -> Date? {
        let now = Date()
        var nextDate:Date? = nil
        
        for item in items {

            let alarm = item.alarm
            
            if alarm.state != .neverFired {
                continue
            }
           
            if alarm.startDate.isAfterDate(now),
               (nextDate == nil || alarm.startDate.isBeforeDate(nextDate!)) {
                nextDate = alarm.startDate
            }
        }

        return nextDate
    }
    
    var nextAlarmDate: Date? {
        let nextEventDate = self.nextAlarmDate(forItems: self.events)
        let nextReminderDate = self.nextAlarmDate(forItems: self.reminders)
        
        if nextEventDate != nil && nextReminderDate != nil {
            return nextEventDate!.isBeforeDate(nextReminderDate!) ? nextEventDate : nextReminderDate
        }
        
        return nextEventDate != nil ? nextEventDate : nextReminderDate
    }
    
}
