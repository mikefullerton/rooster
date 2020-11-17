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
    func calendarManagerDidUpdate(_ calendarManager: CalendarManager)
}

class CalendarData : ObservableObject {
    @Published var calendars: [EventKitCalendar] = []
    @Published var events: [Event] = []
    @Published var reminders: [Reminder] = []
    
    init(withCalendars calendars: [EventKitCalendar],
         events: [Event],
         reminders: [Reminder]) {
        self.calendars = calendars
        self.events = events
        self.reminders = reminders
    }
    
    convenience init() {
        self.init(withCalendars:[], events:[], reminders:[])
    }
}

class CalendarManager: ObservableObject {
    let store: EKEventStore
    
    @Published public var data: CalendarData
        
    weak var delegate: CalendarManagerDelegate?

    static var instance: CalendarManager = {
        return CalendarManager()
    }()
        
    private init() {
        self.store = EKEventStore()
        self.data = CalendarData()
    }

    private func findEvents(withCalendars calendars: [EventKitCalendar]) -> [Event] {
        
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

        let unsubscribedEvents = Preferences.instance.unsubscribedEvents.identifiers
        
        let now = Date()
        
        var events: [Event] = []
        
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
                
                let subscribed = unsubscribedEvents.contains(event.calendarItemIdentifier) == false
                let newEvent = Event(withEvent: event, subscribed: subscribed)
                events.append(newEvent)
            }
        }
        
        return events
    }
    
    private func wantsCalendar(calendar: EKCalendar, subscribedIdentifiers: [String]) -> Bool {
        if calendar.source.title == "apple.com" && calendar.title == "Apple" {
            return true
        }

        if calendar.source.title == "Google" && calendar.title == "Mike Fullerton" {
            return true
        }
        
        return subscribedIdentifiers.contains(calendar.calendarIdentifier)
    }

    private func findCalendars() -> [EventKitCalendar] {
        let subscribedCalenderIdentifiers = Preferences.instance.calendarIdentifers.identifiers
        
        let ekCalendars = self.store.calendars(for: .event)

        var calendars: [EventKitCalendar] = []
        for ekCalendar in ekCalendars {
            
            let subscribed = self.wantsCalendar(calendar: ekCalendar, subscribedIdentifiers: subscribedCalenderIdentifiers)
            
            let calendar = EventKitCalendar(withCalendar: ekCalendar, subscribed:subscribed)
            calendars.append(calendar)
        }

        return calendars
    }
    
    private func findReminders() -> [Reminder] {
        return []
    }

    private func stopAllAlarms() {
        for event in self.data.events {
            if event.isFiring {
                event.stopAlarm()
                event.isFiring = false
                event.hasFired = false
            }
        }
    }
    
    public func reloadData() {
        
        
        let calendars = self.findCalendars()
        let events = self.findEvents(withCalendars: self.data.calendars)
        let reminders = self.findReminders()
        
        self.stopAllAlarms()
        
        self.data.calendars = calendars
        self.data.events = events
        self.data.reminders = reminders
        self.data.objectWillChange.send()

//            = CalendarData(withCalendars: calendars, events: events, reminders: reminders)
    }
    
    @objc private func storeChanged(_ notification: Notification) {
        self.reloadData()
        
        if self.delegate != nil {
            self.delegate!.calendarManagerDidUpdate(self)
        }
    }
    
    private func handleAccessGranted() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.storeChanged(_:)),
                                               name: .EKEventStoreChanged,
                                               object: self.store)
        self.reloadData()
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
    
    var nextEventTime: Date? {
        
        let now = Date()
        
        for event in self.data.events {
            if event.startDate.isAfterDate(now) {
                return event.startDate
            }

            if event.startDate.isAfterDate(now) {
                return event.endDate
            }
        }
        
        let currentCalendar = NSCalendar.current
        
        let dateComponents = currentCalendar.dateComponents([.year, .month, .day], from: Date())
        
        if let today = currentCalendar.date(from: dateComponents),
           let tomorrow: Date = currentCalendar.date(byAdding: .day, value: 1, to: today) {
            
            return tomorrow
        }
        
        return nil
    }
    
    func eventsNeedingAlarms() -> [Event]? {
        let now = Date()
        var events: [Event] = []
        
        for event in self.data.events {
            if event.startDate.isBeforeDate(now) &&
                event.endDate.isAfterDate(now) &&
                event.hasFired == false &&
                event.isFiring == false {
                events.append(event)
            }
        }
        return events
    }
    
    func updateEvent(_ event: Event) {
        var newEvents = self.data.events
        
        if let index = newEvents.firstIndex(of: event) {
            newEvents[index] = event
            print("updated event: \(event)")
        }

        self.data.events = newEvents
    }
    
    func setEventHasFired(_ inEvent: Event) {
        inEvent.setHasFired()
//        self.updateEvent(newEvent)
    }
    
    func setEventIsFiring(_ inEvent: Event) {
//        var newEvent = inEvent
        inEvent.setIsFiring(true)
//        self.updateEvent(newEvent)
    }
    
}
