//
//  EventKitManager+CalendarModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/3/20.
//

import Foundation

extension EventKitManager {
    
    struct CalendarModel {
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
                    guard let calendar = self.calendar(forIdentifier: ekEvent.calendar.calendarIdentifier) else {
                        print("Error couldn't find calendar for id: \(ekEvent.calendar.calendarIdentifier)")
                        continue
                    }
                    
                    let subscribed = Preferences.instance.isEventSubscribed(ekEvent.calendarItemIdentifier)
                    
                    let newEvent = EventKitEvent(withEvent: ekEvent,
                                                 calendar: calendar,
                                                 subscribed: subscribed,
                                                 alarmState: .neverFired)
                    self.events.append(newEvent)
                }
            }
        }
        
        private mutating func addCalendars() {
            for ekCalendar in self.model.calendars {
                if ekCalendar.refresh() {
                    let subscribed = Preferences.instance.isCalendarSubscribed(ekCalendar.calendarIdentifier)
                    
                    let calendar = EventKitCalendar(withCalendar: ekCalendar,
                                                    subscribed:subscribed)
                    
                    self.calendars.append(calendar)
                }
            }
        }
        
        private mutating func addReminders() {
            for ekReminder in self.model.reminders {
                if ekReminder.refresh() {
                    guard let calendar = self.calendar(forIdentifier: ekReminder.calendar.calendarIdentifier) else {
                        print("Error couldn't find calendar for id: \(ekReminder.calendar.calendarIdentifier)")
                        continue
                    }
                    
                    let subscribed = Preferences.instance.isReminderSubscribed(ekReminder.calendarItemIdentifier)

                    let newReminder = EventKitReminder(withReminder: ekReminder,
                                                       calendar: calendar,
                                                       subscribed: subscribed)
                    
                    self.reminders.append(newReminder)
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
