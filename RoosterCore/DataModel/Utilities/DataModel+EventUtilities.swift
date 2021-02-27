//
//  RCCalendarDataModel+EventUtilities.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation

extension RCCalendarDataModel {
    
    private func nextAlarmDate(forItems items: [RCCalendarItem]) -> Date? {
        var nextDate:Date? = nil
        
        for item in items {
            let alarm = item.alarm
            
            if alarm.willFire &&
                (nextDate == nil || alarm.startDate.isBeforeDate(nextDate!)) {
                nextDate = alarm.startDate
            }
        }

        return nextDate
    }
    
    public var nextAlarmDate: Date? {
        let nextEventDate = self.nextAlarmDate(forItems: self.events)
        let nextReminderDate = self.nextAlarmDate(forItems: self.reminders)
        
        if nextEventDate != nil && nextReminderDate != nil {
            return nextEventDate!.isBeforeDate(nextReminderDate!) ? nextEventDate : nextReminderDate
        }
        
        return nextEventDate != nil ? nextEventDate : nextReminderDate
    }
    
}
