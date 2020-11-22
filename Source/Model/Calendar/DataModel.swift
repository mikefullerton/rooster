//
//  DataModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/18/20.
//

import Foundation

typealias SourceToCalendarMap       = [String: [EventKitCalendar]]
typealias CalendarIDToCalendarMap   = [String: EventKitCalendar]

class DataModel : CustomStringConvertible {

    static let DidChangeEvent = Notification.Name("DataModelDidChangeEvent")
    static let NeedsReloadEvent = Notification.Name("NeedsReloadEvent")

    // key: source
    private(set) var calendars: SourceToCalendarMap {
        didSet {
            calendars.forEach { (source, innerCalendars) in
                innerCalendars.forEach { (calendar) in
                    self.didUpdate(calendar: calendar)
                }
            }
        }
    }
    
    // key: source
    private(set) var delegateCalendars: SourceToCalendarMap {
        didSet {
            delegateCalendars.forEach { (source, innerCalendars) in
                innerCalendars.forEach { (calendar) in
                    self.didUpdate(calendar: calendar)
                }
            }
        }
    }
    
    private(set) var events: [EventKitEvent] {
        didSet {
            events.forEach { (event) in
                self.didUpdate(event: event)
            }
        }
    }
    
    private(set) var reminders: [EventKitReminder] {
        didSet {
            reminders.forEach { (reminder) in
                self.didUpdate(reminder: reminder)
            }
        }
    }

    private var calendarLookup: CalendarIDToCalendarMap
    
    let preferences: Preferences
    
    public static let instance: DataModel = DataModel()
    
    private init() {
        self.calendars = [:]
        self.delegateCalendars = [:]
        self.events = []
        self.reminders = []
        self.calendarLookup = [:]
        self.preferences = Preferences()
    }
    
    var description: String {
        return "calenders: \(self.calendars)\ndelegate calendars: \(self.delegateCalendars)\nevents: \(self.events)\nreminders: \(self.reminders)"
    }
    
    private func addCalendars(toMap newMap: inout CalendarIDToCalendarMap, from: SourceToCalendarMap) {
        for (_, calendars) in from {
            for calendar in calendars {
                if newMap[calendar.id] != nil {
                    print("Collision with ID: \(calendar)")
                }
                newMap[calendar.id] = calendar
            }
        }
    }
    
    func calendar(forIdentifier id: String) -> EventKitCalendar? {
        if let calendar = self.calendarLookup[id] {
            return calendar
        }
        return nil;
    }
    

    
    func update(calendars: SourceToCalendarMap,
                delegateCalendars: SourceToCalendarMap,
                events: [EventKitEvent],
                reminders: [EventKitReminder]) {
       
        self.calendarLookup = [:]
        self.delegateCalendars = delegateCalendars
        self.calendars = calendars
        self.events = events
        self.reminders = reminders
        self.notify()
    }
    
    private func notify() {
        NotificationCenter.default.post(name: DataModel.DidChangeEvent, object: self)
    }
    
    private func notifyNeedsReload() {
        NotificationCenter.default.post(name: DataModel.NeedsReloadEvent, object: self)
    }
    
    private func didUpdate(calendar: EventKitCalendar) {
        self.calendarLookup[calendar.id] = calendar
        self.preferences.calendarIdentifers.set(isIncluded: calendar.isSubscribed,
                                                forKey: calendar.id,
                                                notifyListeners: false)
    }

    private func didUpdate(event: EventKitEvent) {
        self.preferences.firedEvents.set(isIncluded: event.hasFired,
                                         forKey: event.id,
                                         notifyListeners: false)
    }
    
    private func didUpdate(reminder: EventKitReminder) {
        
    }
    
    func replace(allEvents: [EventKitEvent]) {
        self.events = allEvents
        self.notifyNeedsReload()
    }
    
    func update(someEvents: [EventKitEvent]) {
        var didMakeChange = false
        var newEvents = self.events
        for event in someEvents {
            if let index = newEvents.firstIndex(of: event),
               event.isEqual(to: newEvents[index]) == false {
                didMakeChange = true
                newEvents[index] = event
                print("updated event: \(event)")
            }
        }
        
        if didMakeChange {
            self.events = newEvents
            self.notifyNeedsReload()
        }
    }
    
    func findEvents(forCalendar calendar: EventKitCalendar) -> [EventKitEvent] {
        var outEvents: [EventKitEvent] = []
        for event in self.events {
            if event.calendarIdentifier == calendar.id {
                outEvents.append(event)
            }
        }
        
        return outEvents
    }
    
    func update(event: EventKitEvent) {
        var newEvents = self.events
        if let index = newEvents.firstIndex(of: event),
           event.isEqual(to: newEvents[index]) == false {
            newEvents[index] = event
            self.events = newEvents
            print("updated event: \(event)")
            self.notifyNeedsReload()
        }
    }
    
    private func update(calendar: EventKitCalendar,
                        inSourceToCalendarMap sourceToCalendarMap: SourceToCalendarMap) -> SourceToCalendarMap? {
        
        var newCalendarMap = sourceToCalendarMap
        
        for (source, calendars) in newCalendarMap {
            if let index = calendars.firstIndex(of: calendar) {
                if calendar.isEqual(to: calendars[index]) == false {
                    var newCalendars = newCalendarMap[source] ?? []
                    newCalendars[index] = calendar
                    newCalendarMap[source] = newCalendars
                    print("DataModel: updated calendar: \(calendar)")
                    return newCalendarMap
                } else {
                    print("DataModel: calendar not different, ignoring change: \(calendar)")
                }
                
                return nil
            }
        }
        return nil
    }
    
    func update(calendar: EventKitCalendar) {
        if let newCalendars = self.update(calendar: calendar, inSourceToCalendarMap: self.calendars) {
            self.calendars = newCalendars
            self.notifyNeedsReload()

        } else if let newDelegateCalendars = self.update(calendar: calendar, inSourceToCalendarMap: self.delegateCalendars) {
            self.delegateCalendars = newDelegateCalendars
            self.notifyNeedsReload()
        } else {
            print("DataModel: calendar not found: \(calendar)")
        }
    }
}

extension EventKitEvent {
    func updatedEvent(isFiring: Bool, hasFired: Bool) -> EventKitEvent {
        return EventKitEvent(withEvent: self.EKEvent,
                             calendarIdentifer: self.calendarIdentifier,
                             subscribed: self.isSubscribed,
                             isFiring: isFiring,
                             hasFired: hasFired)
    }
    
    func stopAlarm() {
        DataModel.instance.update(event: self.updatedEvent(isFiring: false, hasFired: true))
    }
}

extension EventKitCalendar {
    func updatedCalendar(isSubscribed: Bool) -> EventKitCalendar {
        return EventKitCalendar(withCalendar: self.EKCalendar, subscribed: isSubscribed)
    }
    
    func set(subscribed: Bool) {
        DataModel.instance.update(calendar: self.updatedCalendar(isSubscribed: subscribed))
    }
}
