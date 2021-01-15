//
//  EKEventStoreController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/3/20.
//

import Foundation
import EventKit

/// this asychronously fetches all the EKCalendars, EKEvents, and EKReminders we're interested in.
/// All the fetched data is later used to Create our EventKitCalendars, EventKitEvents, and EventKitReminders.
struct EKDataModelFactory: Loggable {

    private let store: EKEventStore?
    let dataModelStorage: DataModelStorage
    
    init(store: EKEventStore?,
         dataModelStorage: DataModelStorage) {
        self.dataModelStorage = dataModelStorage
        self.store = store
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
    
    /// MARK: private

    // TODO: this simple struct shouldn't know about Preferences
    private func subscribedCalendars(_ calendars:[EKCalendar]) -> [EKCalendar] {
        
        var subscribedCalendars: [EKCalendar] = []
        for calendar in calendars {
            let subscribed = self.dataModelStorage.isCalendarSubscribed(calendar.uniqueID)
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
    
    private func calendarNames(forCalendars calendars: [EKCalendar]) -> [String] {
        var list:[String] = []
        calendars.forEach {
            list.append("\($0.source.title): \($0.title)")
        }
        return list
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

            if let participants = event.attendees {
                var iDeclined = false
                for participant in participants {
//                        self.logger.log("\(String(describing: participant.name)): \(participant.participantStatus): \(participant.isCurrentUser)")
                    
                    if participant.isCurrentUser && participant.participantStatus == .declined {
                        iDeclined = true
                        self.logger.log("Found an event the user declined, skipping it: \(event)")
                        break
                    }
                }
            
                if iDeclined {
                    continue
                }
            }
                
//            guard let title = event.title else {
//                continue
//            }

            if endDate.isAfterDate(now) {
                events.append(event)
            }
        }
        
        self.logger.log("Loaded \(events.count) events for calendars: \(self.calendarNames(forCalendars: calendars).joined(separator: ", "))")
        
        return events
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
            
            self.logger.log("Loaded \(fetchedReminders?.count ?? 0) events for calendars: \(self.calendarNames(forCalendars: calendars).joined(separator: ", "))")

            if let reminders = fetchedReminders {
                completion(reminders)
            } else {
                completion([])
            }
        }
    }
}

