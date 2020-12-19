//
//  EKController+IntermediateModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/3/20.
//

import Foundation

extension EventKitManager {
    
    struct IntermediateModel {
        private let personalCalendarModel: CalendarModel
        private let delegateCalendarModel: CalendarModel
        
        private(set) var events: [EventKitEvent]
        private(set) var reminders: [EventKitReminder]
        private(set) var personalCalendars: [CalendarSource: [EventKitCalendar]]
        private(set) var delegateCalendars: [CalendarSource: [EventKitCalendar]]
        
        init(personalCalendarModel: EKDataModel,
             delegateCalendarModel: EKDataModel,
             previousDataModel: EventKitDataModel) {
            
            let personalCalendarModel = CalendarModel(model: personalCalendarModel)
            let delegateCalendarModel = CalendarModel(model: delegateCalendarModel)
            
            self.personalCalendarModel = personalCalendarModel
            self.delegateCalendarModel = delegateCalendarModel
            
            self.personalCalendars = personalCalendarModel.groupedCalendars
            self.delegateCalendars = delegateCalendarModel.groupedCalendars
            
            self.events = IntermediateModel.mergeEvents(personalCalendarModel.events + delegateCalendarModel.events,
                                                        withOldEvents: previousDataModel.events)
            
            self.reminders = IntermediateModel.mergeReminders(personalCalendarModel.reminders + delegateCalendarModel.reminders,
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
                            
                            let updatedItem = updateAlarmBlock(newItem, newAlarm.updatedAlarm(.neverFired))
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
        
        private static func mergeEvents(_ newEvents:[EventKitEvent], withOldEvents oldEvents: [EventKitEvent]) -> [EventKitEvent] {
            return self.mergeItems(newEvents, withOldItems: oldEvents) { newEvent, newAlarm in
                return EventKitEvent(withEvent: newEvent.EKEvent,
                                     calendar: newEvent.calendar,
                                     subscribed: newEvent.isSubscribed,
                                     alarm: newAlarm)
            }
        }
        
        private static func mergeReminders(_ newReminders:[EventKitReminder], withOldReminders oldReminders: [EventKitReminder]) -> [EventKitReminder] {
            return self.mergeItems(newReminders, withOldItems: oldReminders) { newReminder, newAlarm in
                return EventKitReminder(withReminder: newReminder.EKReminder,
                                        calendar: newReminder.calendar,
                                        subscribed: newReminder.isSubscribed,
                                        alarm: newAlarm)
            }
        }
    }
}

