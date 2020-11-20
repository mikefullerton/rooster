//
//  CalenderManager.swift
//  Rooster
//
//  Created by Mike Fullerton on 11/13/20.
//

import Foundation
import EventKit
import UIKit

protocol CalendarManagerDelegate : AnyObject {
    func calendarManagerDidReload(_ calendarManager: CalendarManager)
}

class CalendarManager: ObservableObject {
    private let store: EKEventStore
    private let preferences: Preferences
    private var delegateEventStore: EKEventStore?
    
    @Published public var data: CalendarData
        
    weak var delegate: CalendarManagerDelegate?
        
    init(withPreferences preferences: Preferences) {
        self.store = EKEventStore()
        self.data = CalendarData()
        self.preferences = preferences
        self.delegateEventStore = nil
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
                                                    calendarIdentifer: newEvent.calendarIdentifier,
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
                                                calendarIdentifer: newEvent.calendarIdentifier,
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
        
        return groups
    }

    private func createEvents(fromEKEvents ekEvents:[EKEvent]) -> [EventKitEvent] {
       
        let unsubscribedEvents = self.preferences.unsubscribedEvents

        var events:[EventKitEvent] = []
        
        for ekEvent in ekEvents {
            let subscribed = unsubscribedEvents.contains(ekEvent.calendarItemIdentifier) == false
            let newEvent = EventKitEvent(withEvent: ekEvent,
                                         calendarIdentifer: ekEvent.calendar.calendarIdentifier,
                                         subscribed: subscribed,
                                         isFiring: false,
                                         hasFired: false)
            events.append(newEvent)
        }
        
        return events
    }
    
    public func createCalendars(withEKCalendars ekCalendars: [EKCalendar],
                                events:[EventKitEvent]) -> [EventKitCalendar] {
     
        var calendars:[EventKitCalendar] = []
        
        let subscribedCalendars = self.preferences.calendarIdentifers
        
        for ekCalendar in ekCalendars {
        
            var calendarEvents:[EventKitEvent] = []
            
            for event in events {
                if event.id == ekCalendar.calendarIdentifier {
                    calendarEvents.append(event)
                }
            }
        
            let subscribed = subscribedCalendars.contains(ekCalendar.calendarIdentifier)
            
            let calendar = EventKitCalendar(withCalendar: ekCalendar,
                                            events: calendarEvents,
                                            subscribed:subscribed)
            
            calendars.append(calendar)
        }

        return calendars
    }
    
    func createCalendarLookup(withPersonalCalendars personalCalendars: [EventKitCalendar],
                              delegateCalendars: [EventKitCalendar]) -> [String: EventKitCalendar]{
        
        var lookup: [String: EventKitCalendar] = [:]
        
        for calendar in personalCalendars {
            lookup[calendar.id] = calendar
        }
        
        for calendar in delegateCalendars {
            lookup[calendar.id] = calendar
        }
        
        return lookup
    }
    
    
    public func reloadData() {
        DispatchQueue.main.async {
            self.actuallyReloadData()
        }
    }
    
    private func actuallyReloadData() {
            
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
        
        let events = self.createEvents(fromEKEvents: sortedEKEvents)
        
        self.data.events = self.merge(oldEvents: self.data.events, withNewEvents: events)

        let personalCalendars = self.createCalendars(withEKCalendars: personalEKCalendars, events: self.data.events)

        let delegateCalendars = self.createCalendars(withEKCalendars: delegateEKCalendars, events: self.data.events)
        
        self.data.calendars = self.groupedCalendars(fromCalendars: personalCalendars)
        
        self.data.delegateCalendars = self.groupedCalendars(fromCalendars: delegateCalendars)

        self.data.calenderLookup = self.createCalendarLookup(withPersonalCalendars: personalCalendars,
                                                             delegateCalendars: delegateCalendars)
        
        self.data.reminders = self.findReminders()
        
        self.data.forceUpdate()

        if self.delegate != nil {
            self.delegate!.calendarManagerDidReload(self)
        }
    }
    
    @objc private func storeChanged(_ notification: Notification) {
        self.reloadData()
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
                self.reloadData()
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
    

    
    func updateEvent(_ event: EventKitEvent) {
        var newEvents = self.data.events
        
        if let index = newEvents.firstIndex(of: event) {
            newEvents[index] = event
            print("updated event: \(event)")
        }

        self.data.events = newEvents

        if self.delegate != nil {
            self.delegate!.calendarManagerDidReload(self)
        }
    }
    
    func setEventHasFired(_ inEvent: EventKitEvent) {
        self.updateEvent(inEvent.updatedEvent(isFiring: false, hasFired: true))
    }
    
    func setEventIsFiring(_ inEvent: EventKitEvent) {
        self.updateEvent(inEvent.updatedEvent(isFiring: true, hasFired: false))
    }
    
    

}
