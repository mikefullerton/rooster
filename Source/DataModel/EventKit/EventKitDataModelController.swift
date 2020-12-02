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

    private init() {
        self.eventKitManager = EventKitManager(preferences: Preferences.instance)
        self.dataModel = EventKitDataModel()
        self.preferencesReloader = nil
        self.isAuthenticating = false
        self.isAuthenticated = false

        self.preferencesReloader = PreferencesReloader(for: self)
        self.eventKitManager.delegate = self
    }
    
    func reloadData() {
        self.eventKitManager.reloadData()
        self.needsReload = false
    }
    
    private var needsReload: Bool = false
    
    func setNeedsReloadData() {
        self.needsReload = true
        
        DispatchQueue.main.async {
            if self.needsReload {
                self.reloadData()
            }
        }
    }
    
    static var dataModel: EventKitDataModel {
        return EventKitDataModelController.instance.dataModel
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
                      newCalendarLookup: inout [CalendarID: EventKitCalendar] ) -> [CalendarSource: [EventKitCalendar]] {
        
        var newCalendarMap: [CalendarSource: [EventKitCalendar]] = [:]
        
        for (source, calendars) in self.dataModel.calendars {
            var newCalendarList: [EventKitCalendar] = []
            
            for calendar in calendars {
                if calendar.id == newCalendar.id {
                    newCalendarList.append(newCalendar)
                    newCalendarLookup[source] = newCalendar
                } else {
                    newCalendarList.append(calendar)
                    newCalendarLookup[source] = calendar
                }
            }
            
            newCalendarMap[source] = newCalendarList
        }
        
        return newCalendarMap
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

        self.dataModel = EventKitDataModel(calendars: newCalendarList,
                                           delegateCalendars: newDelegateCalendarList,
                                           events: dataModel.events,
                                           reminders: dataModel.reminders,
                                           calendarLookup: newCalendarLookup)

        Preferences.instance.update(newCalendar)
        self.notify()

        print("EventKitDataModel: updated calendar: \(newCalendar.sourceTitle): \(newCalendar.title)")
    }
    
    private func notify() {
        NotificationCenter.default.post(name: EventKitDataModelController.DidChangeEvent, object: self)
    }
    
    func replace(allEvents: [EventKitEvent]) {
        allEvents.forEach { Preferences.instance.update($0) }
        
        let dataModel = self.dataModel
        self.dataModel = EventKitDataModel(calendars: dataModel.calendars,
                                             delegateCalendars: dataModel.delegateCalendars,
                                             events: allEvents,
                                             reminders: dataModel.reminders,
                                             calendarLookup: dataModel.calendarLookup)
        
        self.notify()
    }
    
    func update(someEvents: [EventKitEvent]) {
        
        var newEventsList: [EventKitEvent] = []

        someEvents.forEach {
            Preferences.instance.update($0)
        }

        for event in self.dataModel.events {
            
            var didAdd = false
            someEvents.forEach {
                if $0.id == event.id {
                    newEventsList.append($0)
                    didAdd = true
                }
            }
            
            if !didAdd {
                newEventsList.append(event)
            }

            print("updated event: \(event)")
        }


        self.dataModel = EventKitDataModel(calendars: dataModel.calendars,
                                             delegateCalendars: dataModel.delegateCalendars,
                                             events: newEventsList,
                                             reminders: dataModel.reminders,
                                             calendarLookup: dataModel.calendarLookup)

        self.notify()
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
        let updatedEvent = self.event(withUpdatedAlarm: .finished)
        
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
