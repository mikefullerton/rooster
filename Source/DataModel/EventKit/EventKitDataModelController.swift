//
//  DataModelController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation

class EventKitDataModelController : EventKitManagerDelegate, Reloadable {
    
    static let DidChangeEvent = Notification.Name("DataModelDidChangeEvent")

    private var preferencesReloader : PreferencesReloader?
    
    private(set) var dataModel: EventKitDataModel

    private let eventKitManager: EventKitManager
    
    public static let instance = EventKitDataModelController()
    
    private(set) var isAuthenticating : Bool

    private(set) var isAuthenticated: Bool

    private var needsNotify = false
    
    private init() {
        self.eventKitManager = EventKitManager(preferences: Preferences.instance)
        self.dataModel = EventKitDataModel()
        self.preferencesReloader = nil
        self.isAuthenticating = false
        self.isAuthenticated = false

        self.preferencesReloader = PreferencesReloader(for: self)
        self.eventKitManager.delegate = self
    }
    
    static var dataModel: EventKitDataModel {
        return EventKitDataModelController.instance.dataModel
    }
    
    public func reloadData() {
        self.eventKitManager.reloadDataModel()
    }
    
    func eventKitManager(_ manager: EventKitManager,
                         didReloadDataModel dataModel: EventKitDataModel) {
     
        self.dataModel = dataModel
        
        self.notify()
    }

    func update(_ event: EventKitEvent) {
        self.update(someEvents: [event])
    }
    
    private func newCalendars(for newCalendar: EventKitCalendar,
                              calendarMap: [CalendarSource: [EventKitCalendar]],
                              newCalendarLookup: inout [CalendarID: EventKitCalendar] ) -> [CalendarSource: [EventKitCalendar]]? {
        
        var newCalendarMap: [CalendarSource: [EventKitCalendar]] = [:]
        
        var foundChange = false
        for (source, calendars) in calendarMap {
            var newCalendarList: [EventKitCalendar] = []
            
            for calendar in calendars {
                if calendar.id == newCalendar.id {
                    if calendar != newCalendar {
                        foundChange = true
                        newCalendarList.append(newCalendar)
                        newCalendarLookup[source] = newCalendar
                    } else {
                        print("Calendar unchanged, ignoring update")
                        newCalendarList.append(calendar)
                        newCalendarLookup[source] = calendar
                    }
                } else {
                    newCalendarList.append(calendar)
                    newCalendarLookup[source] = calendar
                }
            }
            
            newCalendarMap[source] = newCalendarList
        }
        
        return foundChange ? newCalendarMap : nil
    }
    
    func update(_ newCalendar: EventKitCalendar) {
        
        var newCalendarLookup: [CalendarID: EventKitCalendar] = [:]
        
        let dataModel = self.dataModel
        
        let newCalendarList = self.newCalendars(for: newCalendar,
                                                calendarMap: dataModel.calendars,
                                                newCalendarLookup: &newCalendarLookup)

        let newDelegateCalendarList = self.newCalendars(for: newCalendar,
                                                calendarMap: dataModel.delegateCalendars,
                                                newCalendarLookup: &newCalendarLookup)

        if newCalendarList != nil || newDelegateCalendarList != nil {

            let updatedCalendarList = newCalendarList == nil ? self.dataModel.calendars : newCalendarList!
            let updatedDelegateList = newDelegateCalendarList == nil ? self.dataModel.delegateCalendars : newDelegateCalendarList!

            self.dataModel = EventKitDataModel(calendars: updatedCalendarList,
                                               delegateCalendars: updatedDelegateList,
                                               events: dataModel.events,
                                               reminders: dataModel.reminders)
            Preferences.instance.update(newCalendar)
            
            print("EventKitDataModel: updated calendar: \(newCalendar.sourceTitle): \(newCalendar.title)")
            
            self.notify()

            self.eventKitManager.reloadDataModel()
        }
    }
    
    private func notify() {
        self.needsNotify = true
    
        DispatchQueue.main.async {
            self.needsNotify = false
            print("EventDataModel did change notification sent")
            NotificationCenter.default.post(name: EventKitDataModelController.DidChangeEvent, object: self)
        }
    }
        
//    func replace(allEvents: [EventKitEvent]) {
//        allEvents.forEach { Preferences.instance.update($0) }
//
//        let dataModel = self.dataModel
//        self.dataModel = EventKitDataModel(calendars: dataModel.calendars,
//                                             delegateCalendars: dataModel.delegateCalendars,
//                                             events: allEvents,
//                                             reminders: dataModel.reminders)
//
//        self.notify()
//    }
    
    func update(someEvents: [EventKitEvent]) {
        
        var newEventsList: [EventKitEvent] = []

        var foundDifferentEvent = false
        
        for event in self.dataModel.events {
            
            var didAdd = false
            someEvents.forEach {
                if $0.id == event.id {
                    
                    if $0 == event {
                        print("event not changed, ignoring update: \($0)")
                    } else {
                        foundDifferentEvent = true
                        newEventsList.append($0)
                        didAdd = true
                        print("updated event: \($0)")
                    }
                }
            }
            
            if !didAdd {
                newEventsList.append(event)
            }
        }

        if foundDifferentEvent {
            
            someEvents.forEach {
                Preferences.instance.update($0)
            }
            
            self.dataModel = EventKitDataModel(calendars: dataModel.calendars,
                                                 delegateCalendars: dataModel.delegateCalendars,
                                                 events: newEventsList,
                                                 reminders: dataModel.reminders)

            self.notify()
        }
    }
    
    func authenticate(_ completion: ((_ success: Bool) -> Void)? ) {
        self.isAuthenticating = true
        self.eventKitManager.requestAccess { (success, error) in
            DispatchQueue.main.async {
                self.isAuthenticating = false
                if success {
                    self.isAuthenticated = true
                }
                
                if completion != nil {
                    completion!(success)
                }
            }
        }
    }
}

extension EventKitEvent {
    func stopAlarm() {
        let updatedEvent = self.eventWithUpdatedAlarmState(.finished)
        
        EventKitDataModelController.instance.update(updatedEvent)
    }
}

extension EventKitCalendar {
    func updatedCalendar(isSubscribed: Bool) -> EventKitCalendar {
        return EventKitCalendar(withCalendar: self.EKCalendar, subscribed: isSubscribed)
    }
    
    func set(subscribed: Bool) {
        
        let updatedCalendar = self.updatedCalendar(isSubscribed: subscribed)
         
        EventKitDataModelController.instance.update(updatedCalendar)
    }
}
