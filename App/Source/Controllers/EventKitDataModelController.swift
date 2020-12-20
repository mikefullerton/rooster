//
//  DataModelController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation
import OSLog

class EventKitDataModelController : EventKitControllerDelegate, Reloadable {
    
    static let logger = Logger(subsystem: "com.apple.rooster", category: "EventKitDataModelController")
    
    static let DidChangeEvent = Notification.Name("DataModelDidChangeEvent")

    // public properties
    public static let instance = EventKitDataModelController()
    private(set) var dataModel: EventKitDataModel
    private(set) var isAuthenticating : Bool
    private(set) var isAuthenticated: Bool

    // private stuff
    private var preferencesReloader : PreferencesReloader?
    private let eventKitController: EventKitController
    private var needsNotify = false
    
    private init() {
        self.eventKitController = EventKitController(preferences: Preferences.instance)
        self.dataModel = EventKitDataModel()
        self.preferencesReloader = nil
        self.isAuthenticating = false
        self.isAuthenticated = false

        self.preferencesReloader = PreferencesReloader(for: self)
        self.eventKitController.delegate = self
    }
    
    // MARK: convenience accessors
    
    var logger: Logger {
        return EventKitController.logger
    }
    
    public static var dataModel: EventKitDataModel {
        return EventKitDataModelController.instance.dataModel
    }
    
    // MARK: Methods
    
    public func reloadData() {
        self.eventKitController.reloadDataModel()
    }
    
    public func update(calendar newCalendar: EventKitCalendar) {
        
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
            Preferences.instance.update(calendar: newCalendar)
            
            self.logger.log("EventKitDataModel: updated calendar: \(newCalendar.sourceTitle): \(newCalendar.title)")
            
            self.notify()

            self.eventKitController.reloadDataModel()
        }
    }

    public func update(event: EventKitEvent) {
        self.update(someEvents: [event])
    }
    
    public func update(someEvents: [EventKitEvent]) {

        if let updatedEvents = self.update(someItems: someEvents,
                                           inItems: self.dataModel.events) {
            
            updatedEvents.forEach {
                Preferences.instance.update(event: $0)
            }
            
            self.dataModel = EventKitDataModel(calendars: dataModel.calendars,
                                                 delegateCalendars: dataModel.delegateCalendars,
                                                 events: updatedEvents,
                                                 reminders: dataModel.reminders)

            self.notify()
        }
    }
    
    public func update(reminder: EventKitReminder) {
        self.update(someReminders: [reminder] )
    }
    
    public func update(someReminders: [EventKitReminder]) {
        if let updatedReminders = self.update(someItems: someReminders,
                                              inItems: self.dataModel.reminders) {
            
            updatedReminders.forEach {
                Preferences.instance.update(reminder: $0)
            }
            
            self.dataModel = EventKitDataModel(calendars: dataModel.calendars,
                                                 delegateCalendars: dataModel.delegateCalendars,
                                                 events: dataModel.events,
                                                 reminders: updatedReminders)

            self.notify()
        }
    }
    
    public func authenticate(_ completion: ((_ success: Bool) -> Void)? ) {
        self.isAuthenticating = true
        self.eventKitController.requestAccess { (success, error) in
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
    
    // MARK: private implementation
    
    private func update<T>(someItems: [T], inItems: [T]) -> [T]? where T: EventKitItem {
        
        var newItemList: [T] = []

        var foundDifferentItem = false
        
        for item in inItems {
            
            var didAdd = false
            someItems.forEach { (someItem) in
                if someItem.id == item.id {
                    
                    if someItem == item {
                        self.logger.log("event not changed, ignoring update: \(someItem)")
                    } else {
                        foundDifferentItem = true
                        newItemList.append(someItem)
                        didAdd = true
                        self.logger.log("updated event: \(someItem)")
                    }
                }
            }
            
            if !didAdd {
                newItemList.append(item)
            }
        }

        if foundDifferentItem {
            return newItemList
        }
        
        return nil
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
                        self.logger.log("Calendar unchanged, ignoring update")
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
    
    private func notify() {
        self.needsNotify = true
    
        DispatchQueue.main.async {
            self.needsNotify = false
            self.logger.log("EventDataModel did change notification sent")
            NotificationCenter.default.post(name: EventKitDataModelController.DidChangeEvent, object: self)
        }
    }
    
    // MARK: EventKitController delegate method
    
    func eventKitController(_ controller: EventKitController,
                            didReloadDataModel dataModel: EventKitDataModel) {
     
        self.dataModel = dataModel
        
        self.notify()
    }
}

extension EventKitEvent {
    func stopAlarm() {
        
        let updatedAlarm = self.alarm.updatedAlarm(.finished)
        
        let updatedEvent = self.updateAlarm(updatedAlarm)
        
        EventKitDataModelController.instance.update(event: updatedEvent)
    }
}

extension EventKitReminder {
    func stopAlarm() {
        
        let updatedAlarm = self.alarm.updatedAlarm(.finished)
        
        let updatedReminder = self.updateAlarm(updatedAlarm)
        
        EventKitDataModelController.instance.update(reminder: updatedReminder)
    }
    
    func snoozeAlarm() {
        let updatedAlarm = self.alarm.snoozeAlarm(60 * 60 * 2)
        
        let updatedReminder = self.updateAlarm(updatedAlarm)
        
        EventKitDataModelController.instance.update(reminder: updatedReminder)
    }
}

extension EventKitCalendar {
    func updatedCalendar(isSubscribed: Bool) -> EventKitCalendar {
        return EventKitCalendar(withCalendar: self.EKCalendar, subscribed: isSubscribed)
    }
    
    func set(subscribed: Bool) {
        
        let updatedCalendar = self.updatedCalendar(isSubscribed: subscribed)
         
        EventKitDataModelController.instance.update(calendar: updatedCalendar)
    }
}
