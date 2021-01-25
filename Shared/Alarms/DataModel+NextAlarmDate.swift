//
//  DataModel+EventScheduler.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation

extension DataModel {

    private func nextAlarmDateForSchedulingTimer(forItems items: [CalendarItem]) -> Date? {
        let now = Date()
        var nextDate = now.tomorrow
        
        for item in items {

            let alarm = item.alarm
            
            let endDate = alarm.endDate
            if endDate.isAfterDate(now),
               (nextDate == nil || endDate.isBeforeDate(nextDate!)) {
                nextDate = endDate
            }

            if alarm.startDate.isAfterDate(now),
               (nextDate == nil || alarm.startDate.isBeforeDate(nextDate!)) {
                nextDate = alarm.startDate
            }
        }

        return nextDate
    }
    
    var nextAlarmDateForSchedulingTimer: Date? {
        let nextEventDate = self.nextAlarmDateForSchedulingTimer(forItems: self.events)
        let nextReminderDate = self.nextAlarmDateForSchedulingTimer(forItems: self.reminders)
        
        if nextEventDate != nil && nextReminderDate != nil {
            return nextEventDate!.isBeforeDate(nextReminderDate!) ? nextEventDate : nextReminderDate
        }
        
        return nextEventDate != nil ? nextEventDate : nextReminderDate
    }
}
