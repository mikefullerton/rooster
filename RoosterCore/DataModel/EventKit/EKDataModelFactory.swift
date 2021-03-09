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

    private let store: EKEventStore
    let dataModelStorage: DataModelStorage
    let settings: EKDataModelSettings
    init(store: EKEventStore,
         settings: EKDataModelSettings,
         dataModelStorage: DataModelStorage) {
        self.dataModelStorage = dataModelStorage
        self.store = store
        self.settings = settings
    }
    
    func fetchCalendars() -> [EKCalendar] {
        
        var calendars:[EKCalendar] = []
        
        let eventCalendars = self.store.calendars(for: .event)
        let remindersCalendars = self.store.calendars(for: .reminder)
        
        calendars += eventCalendars
        calendars += remindersCalendars
        
        return calendars
    }
    
    func fetchDataModel(withCalendars calendars: [EKCalendar],
                        completion: @escaping (_ dataModel: EKDataModel) -> Void) {
        
        let events = self.fetchEvents(withCalendars: calendars)
        
        self.fetchReminders(withCalendars: calendars) { (reminders) in
            completion(EKDataModel(eventStore: self.store,
                                   calendars:calendars,
                                   events: events,
                                   reminders: reminders))
        }
    }
    
    /// MARK: private

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
    
    private func calendarNames(forCalendars calendars: [EKCalendar]) -> [String] {
        var list:[String] = []
        calendars.forEach {
            list.append("\($0.source.title): \($0.title)")
        }
        return list
    }
    
    private var predicateDates : (startDate: Date, endDate: Date)? {
        let currentCalendar = NSCalendar.current

        let dateComponents = currentCalendar.dateComponents([.year, .month, .day], from: self.settings.startingDay ?? Date())

        guard let startDate = currentCalendar.date(from: dateComponents) else {
            return nil
        }

        guard let endDate: Date = currentCalendar.date(byAdding: .day, value: self.settings.dayCount, to: startDate) else {
            return nil
        }
        
        return (startDate: startDate, endDate: endDate)
    }
    
    private func fetchEvents(withCalendars calendars: [EKCalendar]) -> [EKEvent] {
        
        let subscribedCalendars = self.subscribedCalendars(calendars)
        
        if subscribedCalendars.count == 0 {
            return []
        }
        
        guard let dates = self.predicateDates else {
            return []
        }
        
        var events:[EKEvent] = []

        let predicate = store.predicateForEvents(withStart: dates.startDate,
                                                 end: dates.endDate,
                                                 calendars: subscribedCalendars)

        let now = Date()

        let fetchAllDayEvents = self.settings.allDayEvents
        let fetchDeclinedEvents = self.settings.declinedEvents
        
        for event in store.events(matching: predicate) {
            
            guard let endDate = event.endDate else {
                continue
            }

            if  !fetchDeclinedEvents,
                let participants = event.attendees {
                    
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
            
            if !event.isAllDay,
                !fetchAllDayEvents  {
                continue
            }

            
            if event.isMultiDay && event.occursWithinRange(start: dates.startDate, end: dates.endDate) {
                
                
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
        
        let subscribedCalendars = self.subscribedCalendars(calendars)
        
        if subscribedCalendars.count == 0 {
            completion([])
            return
        }
        
        guard let dates = self.predicateDates else {
            completion([])
            return
        }
        
        let endDateForSearch = self.settings.remindersWithNoDates ? nil : dates.endDate
        
        let predicate = store.predicateForIncompleteReminders(withDueDateStarting: nil,
                                                              ending: endDateForSearch,
                                                              calendars: subscribedCalendars)
        
        store.fetchReminders(matching: predicate) { (fetchedReminders) in
            
            self.logger.log("Loaded \(fetchedReminders?.count ?? 0) reminders for calendars: \(self.calendarNames(forCalendars: calendars).joined(separator: ", "))")

            if let reminders = fetchedReminders {
                completion(reminders)
            } else {
                completion([])
            }
        }
    }
}

extension EKEvent {
    public var isMultiDay: Bool {
        if let days = Date.daysBetween(lhs: self.startDate, rhs: self.endDate) {
            return days > 1
        }
        
        return false
    }
    
    public func occursWithinRange(start: Date, end: Date) -> Bool {
        return Date.range(self.startDate...self.endDate, intersectsRange: start...end)
    }
}
