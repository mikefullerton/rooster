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
    /// Note this is for a single EKEventStore, we later combine the IntermediateDataModels into a Single RCCalendarDataModel
    struct IntermediateDataModel {
        private let model: EKDataModel
        private(set) var calendars: [RCCalendar]
        private(set) var events: [RCEvent]
        private(set) var reminders: [RCReminder]
        private(set) var groupedCalendars: [CalendarSource: [RCCalendar]]
        
        let settings: EKDataModelSettings
        let dataModelStorage: DataModelStorage
        
        init(model: EKDataModel,
             dataModelStorage: DataModelStorage,
             settings: EKDataModelSettings) {
            self.dataModelStorage = dataModelStorage
            self.settings = settings
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
        
        func calendar(forIdentifier identifier: String) -> RCCalendar? {
            return self.calendars.first(where: { $0.id == identifier } )
        }
        
        private mutating func addEvents() {
            for ekEvent in self.model.events {
                guard let calendar = self.calendar(forIdentifier: ekEvent.calendar.uniqueID) else {
                    EKController.logger.error("Error couldn't find calendar for id: \(ekEvent.calendar.uniqueID)")
                    continue
                }

                if let savedState = self.dataModelStorage.eventState(forKey: ekEvent.uniqueID) {
                    self.events.append(RCEvent(withEvent: ekEvent,
                                            calendar: calendar,
                                            savedState: savedState))
                } else {
                    self.events.append( RCEvent(ekEvent: ekEvent,
                                            calendar: calendar,
                                            subscribed: true))
                }
            }
        }
        
        private mutating func addCalendars() {
            if let eventStore = self.model.eventStore {
                for ekCalendar in self.model.calendars {
                    let subscribed = self.dataModelStorage.isCalendarSubscribed(ekCalendar.uniqueID)
                    
                    let calendar = RCCalendar(withIdentifier: ekCalendar.uniqueID,
                                              ekCalendar: ekCalendar,
                                              ekEventStore: eventStore,
                                              settings: self.settings,
                                              isSubscribed:subscribed)
                    
                    self.calendars.append(calendar)
                }
            }
        }
        
        private mutating func addReminders() {
            for ekReminder in self.model.reminders {
                guard let calendar = self.calendar(forIdentifier: ekReminder.calendar.uniqueID) else {
                    EKController.logger.error("Error couldn't find calendar for id: \(ekReminder.calendar.uniqueID)")
                    continue
                }
                // TODO: check alarms?
                
                if ekReminder.isCompleted {
                    continue
                }
                
                if ekReminder.actualDueDate == nil && !self.settings.remindersWithNoDates {
                    continue
                }
                
                if let savedState = self.dataModelStorage.reminderState(forKey: ekReminder.uniqueID) {
                        
                    self.reminders.append(RCReminder(ekReminder: ekReminder,
                                                     calendar: calendar,
                                                     savedState: savedState))
                } else {
                    
                    self.reminders.append(RCReminder(ekReminder: ekReminder,
                                                     calendar: calendar,
                                                     subscribed: true,
                                                     length: self.settings.remindersDuration))
                }
            }
        }
        
        
        private mutating func addGroupedCalendars() {

            for calendar in self.calendars {
                var groupList: [RCCalendar]? = self.groupedCalendars[calendar.sourceTitle]
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
