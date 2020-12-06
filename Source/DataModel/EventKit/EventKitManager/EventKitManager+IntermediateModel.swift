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
             previousEvents: [EventKitEvent]) {
            
            self.personalCalendarModel = CalendarModel(model: personalCalendarModel)
            self.delegateCalendarModel = CalendarModel(model: delegateCalendarModel)
            
            self.personalCalendars = [:]
            self.delegateCalendars = [:]
            self.events = []
            self.reminders = []
            
            self.personalCalendars = self.personalCalendarModel.groupedCalendars
            self.delegateCalendars = self.delegateCalendarModel.groupedCalendars
            
            self.addMergedEvents(withOldEvents: previousEvents)
            self.sortEvents()
            
            self.addReminders()
            self.sortReminders()
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
        
        
        private mutating func addMergedEvents(withOldEvents oldEvents: [EventKitEvent]) {

            let newEvents = self.personalCalendarModel.events + self.delegateCalendarModel.events

            let now = Date()
            
            for newEvent in newEvents {
                var foundEvent = false
                
                for oldEvent in oldEvents {
                    if  newEvent.id == oldEvent.id {
                        foundEvent = true
                                            
                        if  newEvent.startDate.isAfterDate(now) ||
                            (oldEvent.startDate.isAfterDate(now) && newEvent.startDate.isBeforeDate(now)) {
                            
                            // reset if event moved up in time
                            
                            self.events.append(EventKitEvent(withEvent: newEvent.EKEvent,
                                                              calendar: newEvent.calendar,
                                                              subscribed: newEvent.isSubscribed,
                                                              alarm: oldEvent.alarm.updatedAlarm(.neverFired)))

                        } else if newEvent.isHappeningNow {
                            // already load preferences for this event
                            self.events.append(newEvent)
                        
                        } else {
                            
                            // shut it off
                            self.events.append(EventKitEvent(withEvent: newEvent.EKEvent,
                                                              calendar: newEvent.calendar,
                                                              subscribed: newEvent.isSubscribed,
                                                              alarm: oldEvent.alarm.updatedAlarm(.finished)))
                        }
                        
                        continue
                    }
                }
                
                if !foundEvent {
                    self.events.append(newEvent)
                }
            }
        }
    
        private mutating func sortEvents() {
            self.events = self.events.sorted { (lhs, rhs) -> Bool in
                return lhs.startDate.isBeforeDate(rhs.startDate)
            }
        }
        
        private mutating func addReminders() {
            self.reminders += self.personalCalendarModel.reminders
            self.reminders += self.delegateCalendarModel.reminders
            
        }
        
        private mutating func sortReminders() {
            self.reminders = self.reminders.sorted { (lhs, rhs) -> Bool in
                return lhs.dueDate.isBeforeDate(rhs.dueDate)
            }
        }

    }
}

