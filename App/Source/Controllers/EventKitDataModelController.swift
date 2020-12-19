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
    
    func update(calendar newCalendar: EventKitCalendar) {
        
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

    func update(event: EventKitEvent) {
        self.update(someEvents: [event])
    }
    
    private func update<T>(someItems: [T], inItems: [T]) -> [T]? where T: EventKitItem {
        
        var newItemList: [T] = []

        var foundDifferentItem = false
        
        for item in inItems {
            
            var didAdd = false
            someItems.forEach { (someItem) in
                if someItem.id == item.id {
                    
                    if someItem == item {
                        print("event not changed, ignoring update: \(someItem)")
                    } else {
                        foundDifferentItem = true
                        newItemList.append(someItem)
                        didAdd = true
                        print("updated event: \(someItem)")
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
    
    func update(someEvents: [EventKitEvent]) {

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
    
    func update(reminder: EventKitReminder) {
        self.update(someReminders: [reminder] )
    }
    
    func update(someReminders: [EventKitReminder]) {
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
