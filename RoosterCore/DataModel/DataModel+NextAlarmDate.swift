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
        var nextDate = Date.midnightToday
        
        for item in items {

            let alarm = item.alarm
            
            let endDate = alarm.endDate
            if endDate.isAfterDate(now),
               endDate.isBeforeDate(nextDate) {
                nextDate = endDate
            }

            if alarm.startDate.isAfterDate(now),
               alarm.startDate.isBeforeDate(nextDate) {
                nextDate = alarm.startDate
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
