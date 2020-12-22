//
//  EventKitController+CalendarModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/3/20.
//

import Foundation
import EventKit

extension EventKitDataModelFactory {

    /// This takes the data in the EKDataModel and converts it into our EventKit<Type> versions.
    /// When it inflates the object it updates the new inflated object with persisted data for that item.
    /// Note this is for a single EKEventStore, we later combine the IntermediateDataModels into a Single EventKitDataModel
    struct IntermediateDataModel {
        private let model: EKDataModel
        private(set) var calendars: [EventKitCalendar]
        private(set) var events: [EventKitEvent]
        private(set) var reminders: [EventKitReminder]
        private(set) var groupedCalendars: [CalendarSource: [EventKitCalendar]]
        
        init(model: EKDataModel) {
            self.model = model
            self.calendars = []
            self.events = []
            self.reminders = []
            self.groupedCalendars = [:]
                
            self.addCalendars()
            self.addEvents()
            self.addReminders()
            self.addGroupedCalendars()
        }
        
        func calendar(forIdentifier identifier: String) -> EventKitCalendar? {
            return self.calendars.first(where: { $0.id == identifier } )
        }
        
        private mutating func addEvents() {
            for ekEvent in self.model.events {
                if ekEvent.refresh() {
                    guard let calendar = self.calendar(forIdentifier: ekEvent.calendar.uniqueID) else {
                        EventKitController.logger.error("Error couldn't find calendar for id: \(ekEvent.calendar.uniqueID)")
                        continue
                    }
                    
                    var eventKitEvent: EventKitEvent? = nil
                    if let savedState = EventKitDataModel.Storage.instance.eventState(forKey: ekEvent.uniqueID) {
                        eventKitEvent = EventKitEvent(withEvent: ekEvent,
                                                      calendar: calendar,
                                                      savedState: savedState)
                    } else {
                        let alarm = EventKitAlarm(withState: .neverFired,
                                                  startDate: ekEvent.startDate,
                                                  endDate: ekEvent.endDate,
                                                  isEnabled: true,
                                                  snoozeInterval: 0)
                        
                        eventKitEvent = EventKitEvent(withEvent: ekEvent,
                                                      calendar: calendar,
                                                      subscribed: true,
                                                      alarm: alarm)
                    }
                    
                    self.events.append(eventKitEvent!)
                }
            }
        }
        
        private mutating func addCalendars() {
            for ekCalendar in self.model.calendars {
                if ekCalendar.refresh() {
                    let subscribed = EventKitDataModel.Storage.instance.isCalendarSubscribed(ekCalendar.uniqueID)
                    
                    let calendar = EventKitCalendar(withCalendar: ekCalendar,
                                                    subscribed:subscribed)
                    
                    self.calendars.append(calendar)
                }
            }
        }
        
        private mutating func addReminders() {
            for ekReminder in self.model.reminders {
                if ekReminder.refresh() {
                    guard let calendar = self.calendar(forIdentifier: ekReminder.calendar.uniqueID) else {
                        EventKitController.logger.error("Error couldn't find calendar for id: \(ekReminder.calendar.uniqueID)")
                        continue
                    }

                    var startDate: Date? = nil
                    var endDate: Date? = nil
                    
                    if ekReminder.startDateComponents != nil {
                        startDate = ekReminder.startDateComponents!.date
                        
                        endDate = ekReminder.dueDateComponents?.date ?? nil
                        
                    } else if ekReminder.dueDateComponents != nil {
                        startDate = ekReminder.dueDateComponents!.date
                    } else {
                        // todo check alarms?
                    }
                    
                    if startDate == nil || ekReminder.isCompleted {
                        continue
                    }
                    
                    var reminder: EventKitReminder? = nil
                    if let savedState = EventKitDataModel.Storage.instance.reminderState(forKey: ekReminder.uniqueID) {
                        reminder = EventKitReminder(withReminder: ekReminder,
                                                         calendar: calendar,
                                                         startDate: startDate!,
                                                         endDate: endDate,
                                                         savedState: savedState)
                    } else {
                        let alarm = EventKitAlarm(withState: .neverFired,
                                                  startDate: startDate!,
                                                  endDate: endDate,
                                                  isEnabled: true,
                                                  snoozeInterval: 0)
                        
                        reminder = EventKitReminder(withReminder: ekReminder,
                                                    calendar: calendar,
                                                    subscribed: true,
                                                    alarm: alarm)
                    }

                    self.reminders.append(reminder!)
                }
            }
        }
        
        
        private mutating func addGroupedCalendars() {

            for calendar in self.calendars {
                var groupList: [EventKitCalendar]? = self.groupedCalendars[calendar.sourceTitle]
                if groupList == nil {
                    groupList = []
                }
                groupList!.append(calendar)
                self.groupedCalendars[calendar.sourceTitle] = groupList
            }
            
            for (source, calendars) in self.groupedCalendars {
                let sortedList = calendars.sorted {
                    $0.title.localizedCaseInsensitiveCompare($1.title) == ComparisonResult.orderedAscending
                }
                
                self.groupedCalendars[source] = sortedList
            }
        }
    }
}
