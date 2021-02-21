//
//  EKController+CalendarModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/3/20.
//

import Foundation
import EventKit

extension DataModelFactory {

    /// This takes the data in the EKDataModel and converts it into our EventKit<Type> versions.
    /// When it inflates the object it updates the new inflated object with persisted data for that item.
    /// Note this is for a single EKEventStore, we later combine the IntermediateDataModels into a Single DataModel
    struct IntermediateDataModel {
        private let model: EKDataModel
        private(set) var calendars: [Calendar]
        private(set) var events: [Event]
        private(set) var reminders: [Reminder]
        private(set) var groupedCalendars: [CalendarSource: [Calendar]]
        
        let dataModelStorage: DataModelStorage
        
        init(model: EKDataModel,
             dataModelStorage: DataModelStorage) {
            self.dataModelStorage = dataModelStorage
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
        
        func calendar(forIdentifier identifier: String) -> Calendar? {
            return self.calendars.first(where: { $0.id == identifier } )
        }
        
        private mutating func addEvents() {
            for ekEvent in self.model.events {
                if ekEvent.refresh() {
                    guard let calendar = self.calendar(forIdentifier: ekEvent.calendar.uniqueID) else {
                        EKController.logger.error("Error couldn't find calendar for id: \(ekEvent.calendar.uniqueID)")
                        continue
                    }
                    
                    var eventKitEvent: Event? = nil
                    if let savedState = self.dataModelStorage.eventState(forKey: ekEvent.uniqueID) {
                        eventKitEvent = Event(withEvent: ekEvent,
                                                      calendar: calendar,
                                                      savedState: savedState)
                    } else {
                        let alarm = Alarm(startDate: ekEvent.startDate,
                                          endDate: ekEvent.endDate,
                                          isEnabled: true,
                                          mutedDate: nil,
                                          snoozeInterval: 0)
                        
                        eventKitEvent = Event(withEvent: ekEvent,
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
                    let subscribed = self.dataModelStorage.isCalendarSubscribed(ekCalendar.uniqueID)
                    
                    let calendar = Calendar(withCalendar: ekCalendar,
                                                    subscribed:subscribed)
                    
                    self.calendars.append(calendar)
                }
            }
        }
        
        private mutating func addReminders() {
            for ekReminder in self.model.reminders {
                if ekReminder.refresh() {
                    guard let calendar = self.calendar(forIdentifier: ekReminder.calendar.uniqueID) else {
                        EKController.logger.error("Error couldn't find calendar for id: \(ekReminder.calendar.uniqueID)")
                        continue
                    }

                    var startDate: Date? = nil
                    
                    if ekReminder.startDateComponents != nil {
                        startDate = ekReminder.startDateComponents!.date
                    } else if ekReminder.dueDateComponents != nil {
                        startDate = ekReminder.dueDateComponents!.date
                    } else {
                        // todo check alarms?
                    }
                    
                    if startDate == nil || ekReminder.isCompleted {
                        continue
                    }
                    
                    // TODO: hardcoded to 15 minutes
                    let endDate = startDate!.addingTimeInterval(60 * 60 * 15)
                    
                    var reminder: Reminder? = nil
                    if let savedState = self.dataModelStorage.reminderState(forKey: ekReminder.uniqueID) {
                        reminder = Reminder(withReminder: ekReminder,
                                            calendar: calendar,
                                            startDate: startDate!,
                                            endDate: endDate,
                                            savedState: savedState)
                    } else {
                        let alarm = Alarm(startDate: startDate!,
                                          endDate: endDate,
                                          isEnabled: true,
                                          mutedDate: nil,
                                          snoozeInterval: 0)
                        
                        reminder = Reminder(withReminder: ekReminder,
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
                var groupList: [Calendar]? = self.groupedCalendars[calendar.sourceTitle]
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
