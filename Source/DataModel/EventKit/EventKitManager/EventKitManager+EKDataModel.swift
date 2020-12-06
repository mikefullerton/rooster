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
        let calendars:[EKCalendar]
        let events:[EKEvent]
        let reminders:[EKReminder]
        
        func calendar(forIdentifier identifier: String) -> EKCalendar? {
            return self.calendars.first(where: { $0.uniqueID == identifier })
        }
    }
    
    struct EKDataStoreHelper {
        private let store: EKEventStore?
        
        init(store: EKEventStore?) {
            self.store = store
        }
        
        func fetchDataModel(withCalendars calendars: [EKCalendar],
                            completion: @escaping (_ dataModel: EKDataModel) -> Void) {
            
            guard self.store != nil else {
                completion(EKDataModel(calendars: [], events: [], reminders: []))
                return
            }
            
            let events = self.fetchEvents(withCalendars: calendars)
            
            self.fetchReminders(withCalendars: calendars) { (reminders) in
                completion(EKDataModel(calendars:calendars,
                                       events: events,
                                       reminders: reminders))
            }
        }
        
        // TODO: this simple struct shouldn't know about Preferences
        private func subscribedCalendars(_ calendars:[EKCalendar]) -> [EKCalendar] {
            
            var subscribedCalendars: [EKCalendar] = []
            for calendar in calendars {
                let subscribed = Preferences.instance.isCalendarSubscribed(calendar.uniqueID)
                if subscribed {
                    subscribedCalendars.append(calendar)
                }
            }

            return subscribedCalendars
        }
        
        private var predicateDates : (today: Date, tomorrow: Date)? {
            let currentCalendar = NSCalendar.current

            let dateComponents = currentCalendar.dateComponents([.year, .month, .day], from: Date())

            guard let today = currentCalendar.date(from: dateComponents) else {
                return nil
            }

            guard let tomorrow: Date = currentCalendar.date(byAdding: .day, value: 1, to: today) else {
                return nil
            }
            
            return (today: today, tomorrow: tomorrow)
        }
        
        private func fetchEvents(withCalendars calendars: [EKCalendar]) -> [EKEvent] {
            
            guard let store = self.store else {
                return []
            }
            
            let subscribedCalendars = self.subscribedCalendars(calendars)
            
            if subscribedCalendars.count == 0 {
                return []
            }
            
            guard let dates = self.predicateDates else {
                return []
            }
            
            var events:[EKEvent] = []

            let predicate = store.predicateForEvents(withStart: dates.today,
                                                     end: dates.tomorrow,
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
                    events.append(event)
                }
            }
            
            return events
        }
        
        func fetchCalendars() -> [EKCalendar] {
            
            var calendars:[EKCalendar] = []
            
            if let store = self.store {
                let eventCalendars = store.calendars(for: .event)
                let remindersCalendars = store.calendars(for: .reminder)
                
                calendars += eventCalendars
                calendars += remindersCalendars
            }
            
            return calendars
        }
        
        private func fetchReminders(withCalendars calendars: [EKCalendar],
                                    completion: @escaping ([EKReminder])-> Void) {
            
            guard let store = self.store else {
                completion([])
                return
            }
            
            let subscribedCalendars = self.subscribedCalendars(calendars)
            
            if subscribedCalendars.count == 0 {
                completion([])
                return
            }
            
            guard let dates = self.predicateDates else {
                completion([])
                return
            }
            
            let predicate = store.predicateForIncompleteReminders(withDueDateStarting: dates.today,
                                                                  ending: dates.tomorrow,
                                                                  calendars: subscribedCalendars)
            
            store.fetchReminders(matching: predicate) { (fetchedReminders) in
                
                if let reminders = fetchedReminders {
                    completion(reminders)
                } else {
                    completion([])
                }
            }
        }
    }
    
}

extension EKCalendar {
    var uniqueID: String {
        return "\(self.source.sourceIdentifier)+\(self.calendarIdentifier)"
    }
}

extension EKCalendarItem {
    var uniqueID: String {
        return "\(self.calendar.uniqueID)+\(self.calendarItemExternalIdentifier ?? self.calendarItemIdentifier)"
    }
}
