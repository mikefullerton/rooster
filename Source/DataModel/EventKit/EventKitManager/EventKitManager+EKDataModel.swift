//
//  EKEventStoreController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/3/20.
//

import Foundation
import EventKit

extension EventKitManager {
    
    struct EKDataModel {
        private let store: EKEventStore?
        
        private(set) var calendars:[EKCalendar]
        private(set) var events:[EKEvent]
        private(set) var reminders:[EKReminder]
        
        init(store: EKEventStore?) {
            self.store = store

            self.calendars = []
            self.events = []
            self.reminders = []
            
            self.addCalendars()
            self.addEvents()
            self.addReminders()
        }
        
        func calendar(forIdentifier identifier: String) -> EKCalendar? {
            return calendars.first(where: { $0.calendarIdentifier == identifier })
        }
    
        // TODO: this simple struct shouldn't know about Preferences
        private func subscribedCalendars(_ calendars:[EKCalendar]) -> [EKCalendar] {
            
            var subscribedCalendars: [EKCalendar] = []
            for calendar in calendars {
                let subscribed = Preferences.instance.isCalendarSubscribed(calendar.calendarIdentifier)
                if subscribed {
                    subscribedCalendars.append(calendar)
                }
            }

            return subscribedCalendars
        }
        
        private mutating func addEvents() {
            
            guard let store = self.store else {
                return
            }
            
            let subscribedCalendars = self.subscribedCalendars(self.calendars)
            
            if subscribedCalendars.count == 0 {
                return
            }
            
            let currentCalendar = NSCalendar.current

            let dateComponents = currentCalendar.dateComponents([.year, .month, .day], from: Date())

            guard let today = currentCalendar.date(from: dateComponents) else {
                return
            }

            guard let tomorrow: Date = currentCalendar.date(byAdding: .day, value: 1, to: today) else {
                return
            }

            let predicate = store.predicateForEvents(withStart: today,
                                                     end: tomorrow,
                                                     calendars: subscribedCalendars)

            let now = Date()

            for event in store.events(matching: predicate) {

                if event.isAllDay {
                    continue
                }

                guard let endDate = event.endDate else {
                    continue
                }

                if event.status == .canceled {
                    continue
                }

    //            guard let title = event.title else {
    //                continue
    //            }

                if endDate.isAfterDate(now) {
                    self.events.append(event)
                }
            }
        }
        
        private mutating func addCalendars() {
            if let store = self.store {
                let eventCalendars = store.calendars(for: .event)
                let remindersCalendars = store.calendars(for: .reminder)
                
                self.calendars += eventCalendars
                self.calendars += remindersCalendars
            }
        }
        
        private func addReminders() {
        }
    }
}
