//
//  EventKitManager+CalendarModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/3/20.
//

import Foundation
import EventKit

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
                    guard let calendar = self.calendar(forIdentifier: ekEvent.calendar.uniqueID) else {
                        print("Error couldn't find calendar for id: \(ekEvent.calendar.uniqueID)")
                        continue
                    }
                    
                    if let serializer = Preferences.instance.event(forKey: ekEvent.uniqueID) {
                        self.events.append(EventKitEvent(withEvent: ekEvent,
                                                         calendar: calendar,
                                                         subscribed: serializer.isSubscribed,
                                                         alarm: serializer.alarm))

                    } else {
                        
                        let alarm = EventKitAlarm(withState: .neverFired,
                                                  date: ekEvent.startDate,
                                                  isEnabled: true,
                                                  snoozeInterval: 0)
                        
                        self.events.append(EventKitEvent(withEvent: ekEvent,
                                                         calendar: calendar,
                                                         subscribed: true,
                                                         alarm: alarm))
                    }
                    
                }
            }
        }
        
        private mutating func addCalendars() {
            for ekCalendar in self.model.calendars {
                if ekCalendar.refresh() {
                    let subscribed = Preferences.instance.isCalendarSubscribed(ekCalendar.uniqueID)
                    
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
                        print("Error couldn't find calendar for id: \(ekReminder.calendar.uniqueID)")
                        continue
                    }

                    if let serializer = Preferences.instance.reminder(forKey: ekReminder.uniqueID) {
                        self.reminders.append(EventKitReminder(withReminder: ekReminder,
                                                            calendar: calendar,
                                                            subscribed: serializer.isSubscribed,
                                                            alarm: serializer.alarm))

                    } else {
                        
                        if let dueDate = ekReminder.alarmDate,
                           ekReminder.isCompleted == false {
                        
                            let alarm = EventKitAlarm(withState: .neverFired,
                                                  date: dueDate,
                                                  isEnabled: true,
                                                  snoozeInterval: 0)
                        
                            self.reminders.append(EventKitReminder(withReminder: ekReminder,
                                                                   calendar: calendar,
                                                                   subscribed: true,
                                                                   alarm: alarm))
                        }
                    }
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

extension EKReminder {
 
    var alarmDate: Date? {
        guard let dueDateComponents = self.dueDateComponents else {
            return nil
        }
        
        return NSCalendar.current.date(from: dueDateComponents)
    }
}
