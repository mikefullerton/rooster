//
//  RemindersController.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/22/21.
//

import Foundation
import EventKit

public class RemindersController : CalendarItemController {
    
    public func updateDueDate(_ date: Date, forReminder reminder: RCReminder) {
        var newReminder = reminder
        newReminder.dueDate = date
        newReminder.startDate = date
        newReminder.isCompleted = false
        newReminder.completionDate = nil
        newReminder.alarm.isFinished = false
        Controllers.dataModel.update(reminder: newReminder)
        self.save(reminder: newReminder)
    }
    
    public func remindLater(_ reminder: RCReminder) {
        
        if reminder.hasDates {
            if let timeSlot = Controllers.dataModel.findEmptyTimeSlot(forCalendarItem: reminder, withinRange: 2...4) {
                self.updateDueDate(timeSlot.startDate, forReminder: reminder)
            } else {
                
                self.updateDueDate(reminder.dueDate!.removeMinutesAndSeconds.addHours(2), forReminder: reminder)
            }
        } else {

            if let timeSlot = Controllers.dataModel.findEmptyTimeSlot(withEarliestTime:Date(),
                                                                      withLength: reminder.length,
                                                                      withinRange:2...4) {

                self.updateDueDate(timeSlot.startDate, forReminder: reminder)
            } else {
                
                self.updateDueDate(reminder.dueDate!.removeMinutesAndSeconds.addHours(2), forReminder: reminder)
            }
        }
        
    }
    
    public func remindTomorrow( _ reminder: RCReminder) {
        
        let date = Date().removeMinutesAndSeconds.addHours(24)
        
        self.updateDueDate(date, forReminder: reminder)
    }
    
    public func complete( _ reminder: RCReminder) {
        var newReminder = reminder
        newReminder.isCompleted = true
        newReminder.completionDate = Date()
        newReminder.alarm.isFinished = true
        Controllers.dataModel.update(reminder: newReminder)

        self.save(reminder: newReminder)
    }
    
    public func removeDueDates( _ reminder: RCReminder) {
        var newReminder = reminder
        newReminder.isCompleted = false
        newReminder.completionDate = nil
        newReminder.startDate = nil
        newReminder.dueDate = nil
        newReminder.alarm.isFinished = false
        Controllers.dataModel.update(reminder: newReminder)

        self.save(reminder: newReminder)
    }
    
    public func save(reminder: RCReminder) {
        if reminder.hasChanges {
        
            let eventStore = reminder.calendar.ekEventStore
        
            let ekReminder = reminder.updateEKReminder()
            
            do {
                try eventStore.save(ekReminder, commit: true)
            } catch {
                self.showSaveError(forItem:reminder,
                                   informativeText: "",
                                   error:error)
            }
        }
    }
}

extension RCReminder {
    func updateEKReminder() -> EKReminder {
        self.ekReminder.startDateComponents = self.startDate?.components
        self.ekReminder.title = self.title
        self.ekReminder.isCompleted = self.isCompleted
        self.ekReminder.location = self.location
        self.ekReminder.url = self.url
        self.ekReminder.notes = self.notes
        self.ekReminder.priority = self.priority.rawValue
        self.ekReminder.completionDate = self.completionDate
        self.ekReminder.dueDateComponents = self.dueDate?.components
        
        return self.ekReminder
    }

}
