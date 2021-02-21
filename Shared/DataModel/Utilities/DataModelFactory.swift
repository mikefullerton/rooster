//
//  EKController+IntermediateModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/3/20.
//

import Foundation
import EventKit

/// This takes the two IntermediateDataModel structs and combines them into the Single and final DataModel
struct DataModelFactory {

    private let personalCalendarModel: IntermediateDataModel
    private let delegateCalendarModel: IntermediateDataModel
    
    private(set) var events: [Event]
    private(set) var reminders: [Reminder]
    private(set) var personalCalendars: [CalendarSource: [Calendar]]
    private(set) var delegateCalendars: [CalendarSource: [Calendar]]
    
    let dataModelStorage: DataModelStorage
    
    init(personalCalendarModel: EKDataModel,
         delegateCalendarModel: EKDataModel,
         previousDataModel: DataModel,
         dataModelStorage: DataModelStorage) {
        
        self.dataModelStorage = dataModelStorage
        
        let personalCalendarModel = IntermediateDataModel(model: personalCalendarModel, dataModelStorage: dataModelStorage)
        let delegateCalendarModel = IntermediateDataModel(model: delegateCalendarModel, dataModelStorage: dataModelStorage)
        
        self.personalCalendarModel = personalCalendarModel
        self.delegateCalendarModel = delegateCalendarModel
        
        self.personalCalendars = personalCalendarModel.groupedCalendars
        self.delegateCalendars = delegateCalendarModel.groupedCalendars

        self.events = personalCalendarModel.events + delegateCalendarModel.events

        self.reminders = personalCalendarModel.reminders + delegateCalendarModel.reminders

//        self.events = DataModelFactory.mergeEvents(personalCalendarModel.events + delegateCalendarModel.events,
//                                                   withOldEvents: previousDataModel.events)
//
//        self.reminders = DataModelFactory.mergeReminders(personalCalendarModel.reminders + delegateCalendarModel.reminders,
//                                                         withOldReminders: previousDataModel.reminders)
        
        
    }
    
    private func calendar(forIdentifier identifier: String) -> Calendar? {
     
        if let calendar = self.personalCalendarModel.calendar(forIdentifier: identifier) {
            return calendar
        }
        
        if let calendar = self.delegateCalendarModel.calendar(forIdentifier: identifier) {
            return calendar
        }

        return nil
    }
    
//    /// this takes the old list of items and the new list of items updates the state for the new items with the state of the old items if applicable.
//    private static func mergeItems<Item>(_ newItems:[Item],
//                                         withOldItems oldItems: [Item],
//                                         updateAlarmBlock:(_ item: Item, _ newAlarm: Alarm) -> Item ) -> [Item] where Item: CalendarItem {
//
//        var outItems: [Item] = []
//
//        for newItem in newItems {
//            var foundItem = false
//
//            for oldItem in oldItems {
//                if  newItem.id == oldItem.id {
//                    foundItem = true
//
//                    var newAlarm = newItem.alarm
//                    let oldAlarm = oldItem.alarm
//
//                    if newAlarm.isHappeningNow && oldAlarm.isHappeningNow {
//                        // common case of reload during an alarm.
//                        outItems.append(newItem)
//                    } else {
//                        // this always means the alarm is .neverFired
//
//                        newAlarm.state = .neverFired
//
//                        let updatedItem = updateAlarmBlock(newItem, newAlarm)
//                        outItems.append(updatedItem)
//                    }
//                    continue
//                }
//            }
//
//            if !foundItem {
//                outItems.append(newItem)
//            }
//        }
//
//        return outItems.sorted { lhs, rhs in
//            return lhs.alarm.startDate.isBeforeDate(rhs.alarm.startDate)
//        }
//    }
    
//    private static func mergeEvents(_ newEvents:[Event],
//                                    withOldEvents oldEvents: [Event]) -> [Event] {
//
//        return self.mergeItems(newEvents, withOldItems: oldEvents) { newEvent, newAlarm in
//            return Event(withIdentifier: newEvent.id,
//                         ekEventID: newEvent.ekEventID,
//                         externalIdentifier: newEvent.externalIdentifier,
//                         calendar: newEvent.calendar,
//                         subscribed: newEvent.isSubscribed,
//                         alarm: newAlarm,
//                         startDate: newEvent.startDate,
//                         endDate: newEvent.endDate,
//                         title: newEvent.title,
//                         location: newEvent.location,
//                         url: newEvent.url,
//                         notes: newEvent.notes,
//                         organizer: newEvent.organizer)
//
//        }
//    }
//
//    private static func mergeReminders(_ newReminders:[Reminder],
//                                       withOldReminders oldReminders: [Reminder]) -> [Reminder] {
//
//        return self.mergeItems(newReminders, withOldItems: oldReminders) { newReminder, newAlarm in
//            return Reminder(withIdentifier: newReminder.id,
//                            ekReminderID: newReminder.ekReminderID,
//                            externalIdentifier: newReminder.externalIdentifier,
//                            calendar: newReminder.calendar,
//                            subscribed: newReminder.isSubscribed,
//                            completed: newReminder.isCompleted,
//                            alarm: newAlarm,
//                            startDate: newReminder.startDate,
//                            dueDate: newReminder.dueDate,
//                            title: newReminder.title,
//                            location: newReminder.location,
//                            url: newReminder.url,
//                            notes: newReminder.notes)
//
//        }
//    }
//
    /// actually create the final data model
    func createDataModel() -> DataModel {
        return DataModel(calendars: self.personalCalendars,
                         delegateCalendars: self.delegateCalendars,
                         events: self.events,
                         reminders: self.reminders)
    }
    
}

