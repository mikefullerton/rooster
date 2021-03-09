//
//  RCCalendarDataModel+EventScheduler.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation

extension RCCalendarDataModel {

    private func nextAlarmDateForSchedulingTimer(forItems items: [RCCalendarItem]) -> Date? {
        let now = Date()
        var nextDate:Date? = nil
        
        for item in items {

            if  let startDate = item.alarm.startDate,
                let endDate = item.alarm.endDate {
            
                if endDate.isAfterDate(now),
                   (nextDate == nil || endDate.isBeforeDate(nextDate!)) {
                    nextDate = endDate
                }

                if startDate.isAfterDate(now),
                   (nextDate == nil || startDate.isBeforeDate(nextDate!)) {
                    nextDate = startDate
                }
            }
        }

        return nextDate
    }
    
    public var nextAlarmDateForSchedulingTimer: Date? {
        let nextEventDate = self.nextAlarmDateForSchedulingTimer(forItems: self.events)
        let nextReminderDate = self.nextAlarmDateForSchedulingTimer(forItems: self.reminders)
        
        if nextEventDate != nil && nextReminderDate != nil {
            return nextEventDate!.isBeforeDate(nextReminderDate!) ? nextEventDate : nextReminderDate
        }
        
        return nextEventDate != nil ? nextEventDate : nextReminderDate
    }
}
