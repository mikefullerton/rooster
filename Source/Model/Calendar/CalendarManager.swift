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
    func calendarManagerCalendarStoreDidUpdate(_ calendarManager: CalendarManager)
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
    
    private func findEvents(withCalendars calendars: [EventKitCalendar]) -> [EventKitEvent] {
        
        let currentCalendar = NSCalendar.current
        
        let dateComponents = currentCalendar.dateComponents([.year, .month, .day], from: Date())
        
        guard let today = currentCalendar.date(from: dateComponents) else {
            return []
        }
        
        guard let tomorrow: Date = currentCalendar.date(byAdding: .day, value: 1, to: today) else {
            return []
        }
        
        var subscribedCalendars: [EventKitCalendar] = []
        
        for calendar in calendars {
            if calendar.isSubscribed {
                subscribedCalendars.append(calendar)
            }
        }

        let predicate = self.store.predicateForEvents(withStart: today,
                                                      end: tomorrow,
                                                      calendars: subscribedCalendars.map { $0.EKCalendar })

        let unsubscribedEvents = self.preferences.unsubscribedEvents
        
        let now = Date()
        
        var events: [EventKitEvent] = []
        
        for event in self.store.events(matching: predicate) {
            
            if event.isAllDay {
                continue
            }
            
            guard let endDate = event.endDate else {
                continue
            }
            
            guard let title = event.title else {
                continue
            }

            if endDate.isAfterDate(now) {
                print("\(title)")
                if let calendar = self.calendar(forEKCalander: event.calendar, inCalendars: subscribedCalendars) {
                    let subscribed = unsubscribedEvents.contains(event.calendarItemIdentifier) == false
                    let newEvent = EventKitEvent(withEvent: event,
                                                 calendar: calendar,
                                                 subscribed: subscribed,
                                                 isFiring: false,
                                                 hasFired: false)
                    events.append(newEvent)
                }
                
            }
        }
        
        return events
    }
    
    private func calendars(fromEKCalendars ekCalendars: [EKCalendar]) -> [EventKitCalendar] {
        let subscribedCalendars = self.preferences.calendarIdentifers
        var calendars: [EventKitCalendar] = []
        for ekCalendar in ekCalendars {
            
            let subscribed = subscribedCalendars.contains(ekCalendar.calendarIdentifier)
            
            let calendar = EventKitCalendar(withCalendar: ekCalendar,
                                            events: [], // TODO: populate this
                                            subscribed:subscribed)
            calendars.append(calendar)
        }

        return calendars
    }
    
    
    private func findCalendars() -> [EventKitCalendar] {
        let ekCalendars = self.store.calendars(for: .event)
        return self.calendars(fromEKCalendars: ekCalendars)
    }
    
    private func findDelegateCalendars() -> [EventKitCalendar] {
        if self.delegateEventStore == nil {
            return []
        }
        
        let ekCalendars = self.delegateEventStore!.calendars(for: .event)
        return self.calendars(fromEKCalendars: ekCalendars)
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
    
    public func reloadData() {
        let personalCalendars = self.findCalendars()
        let delegateCalendars = self.findDelegateCalendars()
        
        let allCalendars = personalCalendars + delegateCalendars
        
        var groups: [String: [EventKitCalendar]] = [:]
        let events = self.findEvents(withCalendars: allCalendars)
        let reminders = self.findReminders()
        
        for calendar in allCalendars {
            var groupList: [EventKitCalendar]? = groups[calendar.sourceTitle]
            if groupList == nil {
                groupList = []
            }
            groupList!.append(calendar)
            groups[calendar.sourceTitle] = groupList
        }
        
        self.data.calendars = groups
        self.data.events = self.merge(oldEvents: self.data.events, withNewEvents: events)
        self.data.reminders = reminders
        self.data.forceUpdate()

        if self.delegate != nil {
            self.delegate!.calendarManagerDidReload(self)
        }
    }
    
    @objc private func storeChanged(_ notification: Notification) {
        self.reloadData()
        
        if self.delegate != nil {
            self.delegate!.calendarManagerCalendarStoreDidUpdate(self)
        }
    }
    
    private func handleAccessGranted() {
        
        AppDelegate.instance.appKitBundle?.requestPermissionToDelegateCalendars(for: self.store, completion: { (success, delegateEventStore, error) in
            
            if success && delegateEventStore != nil {
                self.delegateEventStore = delegateEventStore!
            }
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.storeChanged(_:)),
                                                   name: .EKEventStoreChanged,
                                                   object: self.store)
            self.reloadData()
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
