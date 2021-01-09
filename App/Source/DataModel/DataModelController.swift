//
//  DataModelController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation

/// interface the app uses to access or update the data model.
class DataModelController : EKControllerDelegate, Loggable {
    
    static let DidChangeEvent = Notification.Name("DataModelDidChangeEvent")

    // public properties
    public static let instance = DataModelController()
    private(set) var dataModel: DataModel {
        didSet {
            self.updateAlarmsIfNeeded()
        }
    }

    private(set) var isAuthenticating : Bool
    private(set) var isAuthenticated: Bool

    // private stuff
    private let eventKitController: EKController
    private var needsNotify = false
    
    private init() {
        self.eventKitController = EKController()
        self.dataModel = DataModel()
        self.isAuthenticating = false
        self.isAuthenticated = false
        
        self.eventKitController.delegate = self
    }
    
    // MARK: convenience accessors

    public static var dataModel: DataModel {
        return DataModelController.instance.dataModel
    }
    
    // MARK: Methods
    
    public func reloadData() {
        self.eventKitController.reloadDataModel()
    }
    
    public func update(calendar newCalendar: Calendar) {
        
        var newCalendarLookup: [CalendarID: Calendar] = [:]
        
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

            self.dataModel = DataModel(calendars: updatedCalendarList,
                                               delegateCalendars: updatedDelegateList,
                                               events: dataModel.events,
                                               reminders: dataModel.reminders)
            DataModel.Storage.instance.update(calendar: newCalendar)
            
            self.logger.log("DataModel: updated calendar: \(newCalendar.sourceTitle): \(newCalendar.title)")
            
            self.notify()

            self.reloadData()        }
    }

    public func update(event: Event) {
        self.update(someEvents: [event])
    }
    
    public func update(someEvents: [Event]) {

        if let updatedEvents = self.update(someItems: someEvents,
                                           inItems: self.dataModel.events) {
            
            updatedEvents.forEach {
                DataModel.Storage.instance.update(event: $0)
            }
            
            self.dataModel = DataModel(calendars: dataModel.calendars,
                                               delegateCalendars: dataModel.delegateCalendars,
                                               events: updatedEvents,
                                               reminders: dataModel.reminders)

            self.notify()
        }
    }
    
    public func update(reminder: Reminder) {
        self.update(someReminders: [reminder] )
    }
    
    public func update(someReminders: [Reminder]) {
        if let updatedReminders = self.update(someItems: someReminders,
                                              inItems: self.dataModel.reminders) {
            
            updatedReminders.forEach {
                DataModel.Storage.instance.update(reminder: $0)
            }
            
            self.dataModel = DataModel(calendars: dataModel.calendars,
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
    
    private func update<T>(someItems: [T], inItems: [T]) -> [T]? where T: CalendarItem {
        
        var newItemList: [T] = []

        var foundDifferentItem = false
        
        for item in inItems {
            
            var didAdd = false
            someItems.forEach { (someItem) in
                if someItem.id == item.id {
                    
                    if someItem.isEqualTo(item) {
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
    
    private func newCalendars(for newCalendar: Calendar,
                              calendarMap: [CalendarSource: [Calendar]],
                              newCalendarLookup: inout [CalendarID: Calendar] ) -> [CalendarSource: [Calendar]]? {
        
        var newCalendarMap: [CalendarSource: [Calendar]] = [:]
        
        var foundChange = false
        for (source, calendars) in calendarMap {
            var newCalendarList: [Calendar] = []
            
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
            if self.needsNotify {
                self.needsNotify = false
                self.logger.log("EventDataModel did change notification sent")
                NotificationCenter.default.post(name: DataModelController.DidChangeEvent, object: self)
            }
        }
    }
    
    // MARK: EKController delegate method
    
    func eventKitController(_ controller: EKController,
                            didReloadDataModel dataModel: DataModel) {
     
        self.dataModel = dataModel
        
        self.notify()
    }
    
    // MARK: Alarms
    
    func stopAllAlarms() {
        if let updatedEvents = self.stopAlarms(forItems: DataModelController.dataModel.events)  {
            self.update(someEvents: updatedEvents)
        }

        if let updatedReminders = self.stopAlarms(forItems: DataModelController.dataModel.reminders) {
            self.update(someReminders: updatedReminders)
        }
    }
    
    private func stopAlarms<T>(forItems items: [T]) -> [T]? where T: CalendarItem {
        var outList:[T] = []
        var madeChange = false
        
        for item in items {
            if item.alarm.state == .firing {
                var updatedAlarm = item.alarm
                updatedAlarm.state = .finished
                
                var updatedItem = item
                updatedItem.alarm = updatedAlarm
                outList.append(updatedItem)
                
                madeChange = true
            } else {
                outList.append(item)
            }
        }
        
        return madeChange ? outList : nil
    }
    
    private func updateAlarms<T>(forItems items: [T]) -> [T]? where T: CalendarItem {
        var outList:[T] = []
        var madeChange = false
        
        for item in items {
            let alarm = item.alarm
            var alarmState = alarm.state
            
            if !alarm.isEnabled {
                alarmState = .disabled
            
            } else if alarm.isHappeningNow {
                
                if alarmState == .neverFired {
                    alarmState = .firing
                }
                    
            } else {
                alarmState = .neverFired
            }
            
            if alarmState != alarm.state {
                
                var updatedAlarm = alarm
                updatedAlarm.state = alarmState
                
                var updatedItem = item
                updatedItem.alarm = updatedAlarm
                outList.append(updatedItem)

                madeChange = true
            } else {
                outList.append(item)
            }
                
        }
        
        return madeChange ? outList : nil
    }
    
    private func updateAlarmsIfNeeded() {
        if let updatedEvents = self.updateAlarms(forItems: self.dataModel.events)  {
            self.update(someEvents: updatedEvents)
        }
    
        if let updatedReminders = self.updateAlarms(forItems: self.dataModel.reminders) {
            self.update(someReminders: updatedReminders)
        }
    }

}

extension Event {
    func stopAlarm() {
        var newAlarm = self.alarm
        newAlarm.state = .finished
        
        var newEvent = self
        newEvent.alarm = newAlarm
        
        DataModelController.instance.update(event: newEvent)
    }
}

extension Reminder {
    func stopAlarm() {
        var newAlarm = self.alarm
        newAlarm.state = .finished
        
        var newReminder = self
        newReminder.alarm = newAlarm
        
        DataModelController.instance.update(reminder: newReminder)
    }
    
    func snoozeAlarm() {
        var updatedAlarm = self.alarm
        updatedAlarm.snoozeInterval += 60 * 60 * 2
        
        var newReminder = self
        newReminder.alarm = updatedAlarm
        
        DataModelController.instance.update(reminder: newReminder)
    }
}

extension Calendar {
    func set(subscribed: Bool) {
        var updatedCalendar = self
        updatedCalendar.isSubscribed = subscribed
        DataModelController.instance.update(calendar: updatedCalendar)
    }
}
