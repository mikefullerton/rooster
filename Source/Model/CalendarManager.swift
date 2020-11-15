//
//  CalenderManager.swift
//  Rooster
//
//  Created by Mike Fullerton on 11/13/20.
//

import Foundation
import EventKit


class CalendarManager {
    let store: EKEventStore
    var calendars: [Calendar] = []
    var events: [Event] = []
    var reminders: [Reminder] = []

    static var instance = CalendarManager()
    
    private init() {
        self.store = EKEventStore()
    }

//    private func wantsCalendar(calendar: EKCalendar) -> Bool {
//        if calendar.source.title == "apple.com" && calendar.title == "Apple" {
//            return true
//        }
//        
//        if calendar.source.title == "Google" && calendar.title == "Mike Fullerton" {
//            return true
//        }
//        
////        if Preferences.instance.calendarId
//        
//        return false
//    }

    private func addEvents() {
        
        let currentCalendar = NSCalendar.current
        
        let dateComponents = currentCalendar.dateComponents([.year, .month, .day], from: Date())
        
        guard let today = currentCalendar.date(from: dateComponents) else {
            return
        }
        
        guard let tomorrow: Date = currentCalendar.date(byAdding: .day, value: 1, to: today) else {
            return
        }
        
        let predicate = self.store.predicateForEvents(withStart: today,
                                                      end: tomorrow,
                                                      calendars: self.calendars.map { $0.EKCalendar })
        
        
        let unsubscribedEvents = Preferences.instance.unsubscribedEvents.identifiers
        
        let now = Date()
        
        for event in self.store.events(matching: predicate) {
            
            if event.isAllDay {
                continue
            }
            
            guard let startDate = event.startDate else {
                continue
            }
            
            guard let title = event.title else {
                continue
            }

            let comparison = now.compare(startDate)
            
            if comparison != .orderedDescending {
                print("\(title)")
                
                let subscribed = unsubscribedEvents.contains(event.calendarItemIdentifier) == false
                let newEvent = Event(withEvent: event, subscribed: subscribed)
                self.events.append(newEvent)
            }
        }
    }
    
    private func addCalendars() {
        let subscribedCalenderIdentifiers = Preferences.instance.calendarIdentifers.identifiers
        
        let ekCalendars = self.store.calendars(for: .event)
        
        for ekCalendar in ekCalendars {
            let calendar = Calendar(withCalendar: ekCalendar, subscribed: subscribedCalenderIdentifiers.contains(ekCalendar.calendarIdentifier))
            self.calendars.append(calendar)
        }
    }

    private func configure() {
        self.calendars = []
        self.events = []
        self.addCalendars()
        self.addEvents()
    }
    
    @objc private func storeChanged(_ notification: Notification) {
        self.configure()
    }
    
    private func handleAccessGranted() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.storeChanged(_:)),
                                               name: .EKEventStoreChanged,
                                               object: self.store)
        self.configure()
    }
    
    private func handleAccessDenied(error: Error?) {
        
    }
    
    public typealias CalendarManagerCompletionBlock = (_ success: Bool, _ error: Error?) -> Void
    
    private func requestAccess(to entityType: EKEntityType, completion: @escaping CalendarManagerCompletionBlock) {
        self.store.requestAccess(to: entityType, completion: { (success: Bool, error: Error?) in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    completion(success, error)
                }
            }
        })
    }
    
    func requestAccess(completion: @escaping CalendarManagerCompletionBlock) {
        self.requestAccess(to: EKEntityType.event) { (success, error) in
            if success == true {
                self.requestAccess(to: EKEntityType.reminder) { (innerSuccess, innerError) in
                    if innerSuccess == true {
                        self.handleAccessGranted()
                    } else {
                        self.handleAccessDenied(error: innerError)
                    }
                    
                    completion(innerSuccess, innerError)
                }
            } else {
                completion(success, error)
            }
        }
    }
}
