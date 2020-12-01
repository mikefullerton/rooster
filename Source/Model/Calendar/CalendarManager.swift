//
//  CalenderManager.swift
//  Rooster
//
//  Created by Mike Fullerton on 11/13/20.
//

import Foundation
import EventKit

class CalendarManager {
    private let store: EKEventStore
    private var delegateEventStore: EKEventStore?
    private let preferences: Preferences
    private let dataModel: DataModel
    
    init(withDataModel dataModel: DataModel, preferences: Preferences) {
        self.store = EKEventStore()
        self.delegateEventStore = nil
        self.preferences = preferences
        self.dataModel = dataModel

        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: Preferences.DidChangeEvent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dataModelUpdated(_:)), name: DataModel.NeedsReloadEvent, object: nil)

    }
    
    @objc private func preferencesDidChange(_ notif: Notification) {
        self.self.reloadDataModel()
    }

    @objc private func dataModelUpdated(_ notif: Notification) {
        self.self.reloadDataModel()
    }

    private func calendar(forEKCalander ekCalendar: EKCalendar, inCalendars calendars: [EventKitCalendar]) -> EventKitCalendar? {
        return calendars.first(where: { $0.id == ekCalendar.calendarIdentifier })
    }
    
    private func subscribedCalendars(_ calendars:[EKCalendar]) -> [EKCalendar] {
        let subscribedCalendarIdentifiers = self.preferences.calendarIdentifers
        
        var subscribedCalendars: [EKCalendar] = []
        for calendar in calendars {
            let subscribed = subscribedCalendarIdentifiers.contains(calendar.calendarIdentifier)
            if subscribed {
                subscribedCalendars.append(calendar)
            }
        }

        return subscribedCalendars
    }
    
    private func findEvents(withEKCalendars calendars: [EKCalendar],
                            store: EKEventStore) -> [EKEvent] {
        
        let subscribedCalendars = self.subscribedCalendars(calendars)
        
        if subscribedCalendars.count == 0 {
            return []
        }
        
        let currentCalendar = NSCalendar.current

        let dateComponents = currentCalendar.dateComponents([.year, .month, .day], from: Date())

        guard let today = currentCalendar.date(from: dateComponents) else {
            return []
        }

        guard let tomorrow: Date = currentCalendar.date(byAdding: .day, value: 1, to: today) else {
            return []
        }

        let predicate = store.predicateForEvents(withStart: today,
                                                 end: tomorrow,
                                                 calendars: subscribedCalendars)


        let now = Date()

        var events:[EKEvent] = []

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
    
    private func findCalendars() -> [EKCalendar] {
        return self.store.calendars(for: .event)
    }
    
    private func findDelegateCalendars() -> [EKCalendar] {
        if self.delegateEventStore == nil {
            return []
        }
        
        return self.delegateEventStore!.calendars(for: .event)
    }
    
    
    private func findReminders() -> [EventKitReminder] {
        return []
    }
    
    private func merge(oldEvents: [EventKitEvent],
                       withNewEvents newEvents: [EventKitEvent]) -> [EventKitEvent] {
        
        var mergedEvents: [EventKitEvent] = []
        let firedIdentifiers = self.preferences.firedEvents
        
        let now = Date()
        
        for newEvent in newEvents {
            var foundEvent = false
            
            for oldEvent in oldEvents {
                if  newEvent.id == oldEvent.id {
                    foundEvent = true
                    
                    var hasFired = oldEvent.hasFired
                    
                    if newEvent.startDate.isAfterDate(now) {
                        hasFired = false
                    } else if oldEvent.startDate.isAfterDate(now) && newEvent.startDate.isBeforeDate(now) {
                        hasFired = false
                    } else if newEvent.isInProgress && firedIdentifiers.contains(newEvent.id) {
                        hasFired = true
                    }
                    
                    let mergedEvent = EventKitEvent(withEvent: newEvent.EKEvent,
                                                    calendar: newEvent.calendar,
                                                    subscribed: newEvent.isSubscribed,
                                                    isFiring: oldEvent.isFiring,
                                                    hasFired: hasFired)

                    mergedEvents.append(mergedEvent)
                    continue
                }
            }
            
            if !foundEvent {
                
                var hasFired = newEvent.hasFired
                
                if newEvent.isInProgress && firedIdentifiers.contains(newEvent.id) {
                    hasFired = true
                }
                
                let mergedEvent = EventKitEvent(withEvent: newEvent.EKEvent,
                                                calendar: newEvent.calendar,
                                                subscribed: newEvent.isSubscribed,
                                                isFiring: newEvent.isFiring,
                                                hasFired: hasFired)
                
                mergedEvents.append(mergedEvent)
            }
        }

        return mergedEvents
    }
    
    public func groupedCalendars(fromCalendars calendars: [EventKitCalendar]) -> [String: [EventKitCalendar]] {
        var groups: [String: [EventKitCalendar]] = [:]

        for calendar in calendars {
            var groupList: [EventKitCalendar]? = groups[calendar.sourceTitle]
            if groupList == nil {
                groupList = []
            }
            groupList!.append(calendar)
            groups[calendar.sourceTitle] = groupList
        }
        
        for (source, calendars) in groups {
            let sortedList = calendars.sorted {
                $0.title.localizedCaseInsensitiveCompare($1.title) == ComparisonResult.orderedAscending
            }
            
            groups[source] = sortedList
        }
        
        
        return groups
    }

    private func createEvents(fromEKEvents ekEvents:[EKEvent],
                              calendars: [String: EventKitCalendar]) -> [EventKitEvent] {
       
        let unsubscribedEvents = self.preferences.unsubscribedEvents

        var events:[EventKitEvent] = []
        
        for ekEvent in ekEvents {
            let subscribed = unsubscribedEvents.contains(ekEvent.calendarItemIdentifier) == false
            
            guard let calendar = calendars[ekEvent.calendar.calendarIdentifier] else {
                print("Error couldn't find calendar for id: \(ekEvent.calendar.calendarIdentifier)")
                continue
            }
            
            let newEvent = EventKitEvent(withEvent: ekEvent,
                                         calendar: calendar,
                                         subscribed: subscribed,
                                         isFiring: false,
                                         hasFired: false)
            events.append(newEvent)
        }
        
        return events
    }
    
    public func createCalendars(withEKCalendars ekCalendars: [EKCalendar]) -> [EventKitCalendar] {
     
        var calendars:[EventKitCalendar] = []
        
        let subscribedCalendars = self.preferences.calendarIdentifers
        
        for ekCalendar in ekCalendars {
            let subscribed = subscribedCalendars.contains(ekCalendar.calendarIdentifier)
            
            let calendar = EventKitCalendar(withCalendar: ekCalendar,
                                            subscribed:subscribed)
            
            calendars.append(calendar)
        }

        return calendars
    }

    public func createCalendarLookup(calendars: [EventKitCalendar],
                                     delegateCalendars: [EventKitCalendar]) -> [String: EventKitCalendar] {
        
        var lookup: [String: EventKitCalendar] = [:]
        
        calendars.forEach { lookup[$0.id] = $0 }
        delegateCalendars.forEach { lookup[$0.id] = $0 }
        
        return lookup
    }
    
    public func reloadDataModel() {
        DispatchQueue.main.async {
            self.actuallyReloadDataModel()
        }
    }
    
    private func actuallyReloadDataModel() {
            
        let personalEKCalendars = self.findCalendars()
        
        let delegateEKCalendars = self.findDelegateCalendars()
        
        let ekPersonalEvents = self.findEvents(withEKCalendars: personalEKCalendars,
                                               store: self.store)
        
        let ekDelegateEvents = self.delegateEventStore != nil ?
                                    self.findEvents(withEKCalendars: delegateEKCalendars,
                                                    store:self.delegateEventStore!) : []
        
        let ekEvents = ekPersonalEvents + ekDelegateEvents
        
        let sortedEKEvents = ekEvents.sorted { (lhs, rhs) -> Bool in
            return lhs.startDate.isBeforeDate(rhs.startDate)
        }

        let personalCalendars = self.createCalendars(withEKCalendars: personalEKCalendars)

        let delegateCalendars = self.createCalendars(withEKCalendars: delegateEKCalendars)

        let calendarLookup = self.createCalendarLookup(calendars: personalCalendars,
                                                       delegateCalendars: delegateCalendars)
        
        let events = self.createEvents(fromEKEvents: sortedEKEvents,
                                       calendars:calendarLookup)
        
        let previousEvents = self.dataModel.events
        
        let finalEvents = self.merge(oldEvents: previousEvents, withNewEvents: events)

        let finalCalendars = self.groupedCalendars(fromCalendars: personalCalendars)
        
        let finalDelegateCalendars = self.groupedCalendars(fromCalendars: delegateCalendars)
        
        let finalReminders = self.findReminders()
        
        self.dataModel.update(calendars: finalCalendars,
                              delegateCalendars: finalDelegateCalendars,
                              events: finalEvents,
                              reminders: finalReminders,
                              calendarLookup: calendarLookup)
    }
    
    @objc private func storeChanged(_ notification: Notification) {
        self.reloadDataModel()
    }
    
    private func handleAccessGranted() {
        
        AppDelegate.instance.appKitBundle?.requestPermissionToDelegateCalendars(for: self.store, completion: { (success, delegateEventStore, error) in
            DispatchQueue.main.async {
                if success && delegateEventStore != nil {
                    self.delegateEventStore = delegateEventStore!
                }
                
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(self.storeChanged(_:)),
                                                       name: .EKEventStoreChanged,
                                                       object: self.store)
                self.reloadDataModel()
            }
        })
    }
    
    private func handleAccessDenied(error: Error?) {
        
    }
    
    public typealias CalendarManagerCompletionBlock = (_ success: Bool, _ error: Error?) -> Void
    
    private func requestAccess(to entityType: EKEntityType, completion: @escaping CalendarManagerCompletionBlock) {
        self.store.requestAccess(to: entityType, completion: { (success: Bool, error: Error?) in
            completion(success, error)
        })
    }
    
    func requestAccess(completion: @escaping CalendarManagerCompletionBlock) {
        
        var count = 0
        var errorResults: [Error?] = [ nil, nil ]
        var successResults: [Bool] = [ false, false ]
        
        let completion: CalendarManagerCompletionBlock = { (success, error) in
            
            count += 1
            
            if count == 1 {
                successResults[0] = success
                errorResults[0] = error
            } else {
                successResults[1] = success
                errorResults[1] = error
            
                DispatchQueue.main.async {
                    
                    if success {
                        self.handleAccessGranted()
                    } else {
                        self.handleAccessDenied(error: error)
                    }
                    
                    completion(success, error)
                }
            }
        }
        
        self.requestAccess(to: EKEntityType.event, completion: completion)
        self.requestAccess(to: EKEntityType.reminder, completion: completion)
        
    }
}
