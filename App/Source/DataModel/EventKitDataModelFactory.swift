//
//  EKController+IntermediateModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/3/20.
//

import Foundation
import EventKit

/// This takes the two IntermediateDataModel structs and combines them into the Single and final EventKitDataModel
struct EventKitDataModelFactory {

    private let personalCalendarModel: IntermediateDataModel
    private let delegateCalendarModel: IntermediateDataModel
    
    private(set) var events: [EventKitEvent]
    private(set) var reminders: [EventKitReminder]
    private(set) var personalCalendars: [CalendarSource: [EventKitCalendar]]
    private(set) var delegateCalendars: [CalendarSource: [EventKitCalendar]]
    
    init(personalCalendarModel: EKDataModel,
         delegateCalendarModel: EKDataModel,
         previousDataModel: EventKitDataModel) {
        
        let personalCalendarModel = IntermediateDataModel(model: personalCalendarModel)
        let delegateCalendarModel = IntermediateDataModel(model: delegateCalendarModel)
        
        self.personalCalendarModel = personalCalendarModel
        self.delegateCalendarModel = delegateCalendarModel
        
        self.personalCalendars = personalCalendarModel.groupedCalendars
        self.delegateCalendars = delegateCalendarModel.groupedCalendars
        
        self.events = EventKitDataModelFactory.mergeEvents(personalCalendarModel.events + delegateCalendarModel.events,
                                                           withOldEvents: previousDataModel.events)
        
        self.reminders = EventKitDataModelFactory.mergeReminders(personalCalendarModel.reminders + delegateCalendarModel.reminders,
                                                                 withOldReminders: previousDataModel.reminders)
        
        
    }
    
    private func calendar(forIdentifier identifier: String) -> EventKitCalendar? {
     
        if let calendar = self.personalCalendarModel.calendar(forIdentifier: identifier) {
            return calendar
        }
        
        if let calendar = self.delegateCalendarModel.calendar(forIdentifier: identifier) {
            return calendar
        }

        return nil
    }
    
    /// this takes the old list of items and the new list of items updates the state for the new items with the state of the old items if applicable.
    private static func mergeItems<Item>(_ newItems:[Item],
                                         withOldItems oldItems: [Item],
                                         updateAlarmBlock:(_ item: Item, _ newAlarm: EventKitAlarm) -> Item ) -> [Item] where Item: EventKitItem {
        
        var outItems: [Item] = []
        
        for newItem in newItems {
            var foundItem = false
            
            for oldItem in oldItems {
                if  newItem.id == oldItem.id {
                    foundItem = true
                    
                    let newAlarm = newItem.alarm
                    let oldAlarm = oldItem.alarm
                    
                    if newAlarm.isHappeningNow && oldAlarm.isHappeningNow {
                        // common case of reload during an alarm.
                        outItems.append(newItem)
                    } else {
                        // this always means the alarm is .neverFired
                        let updatedItem = updateAlarmBlock(newItem, newAlarm.alarmWithUpdatedState(.neverFired))
                        outItems.append(updatedItem)
                    }
                    continue
                }
            }
            
            if !foundItem {
                outItems.append(newItem)
            }
        }
        
        return outItems.sorted { lhs, rhs in
            return lhs.alarm.startDate.isBeforeDate(rhs.alarm.startDate)
        }
    }
    
    private static func mergeEvents(_ newEvents:[EventKitEvent],
                                    withOldEvents oldEvents: [EventKitEvent]) -> [EventKitEvent] {
        
        return self.mergeItems(newEvents, withOldItems: oldEvents) { newEvent, newAlarm in
            return EventKitEvent(withIdentifier: newEvent.id,
                                 ekEventID: newEvent.ekEventID,
                                 calendar: newEvent.calendar,
                                 subscribed: newEvent.isSubscribed,
                                 alarm: newAlarm,
                                 startDate: newEvent.startDate,
                                 endDate: newEvent.endDate,
                                 title: newEvent.title,
                                 location: newEvent.location,
                                 url: newEvent.url,
                                 notes: newEvent.notes,
                                 noteURLS: newEvent.noteURLS,
                                 organizer: newEvent.organizer)

        }
    }
    
    private static func mergeReminders(_ newReminders:[EventKitReminder],
                                       withOldReminders oldReminders: [EventKitReminder]) -> [EventKitReminder] {
        
        return self.mergeItems(newReminders, withOldItems: oldReminders) { newReminder, newAlarm in
            return EventKitReminder(withIdentifier: newReminder.id,
                                    ekReminderID: newReminder.ekReminderID,
                                    calendar: newReminder.calendar,
                                    subscribed: newReminder.isSubscribed,
                                    completed: newReminder.isCompleted,
                                    alarm: newAlarm,
                                    startDate: newReminder.startDate,
                                    dueDate: newReminder.dueDate,
                                    title: newReminder.title,
                                    location: newReminder.location,
                                    url: newReminder.url,
                                    notes: newReminder.notes,
                                    noteURLS: newReminder.noteURLS)

        }
    }
    
    /// actually create the final data model
    func createDataModel() -> EventKitDataModel {
        return EventKitDataModel(calendars: self.personalCalendars,
                                 delegateCalendars: self.delegateCalendars,
                                 events: self.events,
                                 reminders: self.reminders)
    }
    
}

