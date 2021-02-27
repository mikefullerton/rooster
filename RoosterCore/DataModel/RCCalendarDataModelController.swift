//
//  RCCalendarDataModelController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation

/// interface the app uses to access or update the data model.
public class RCCalendarDataModelController : EKControllerDelegate, Loggable {
    
    public static let DidChangeEvent = Notification.Name("DataModelDidChangeEvent")

    // public properties
    private(set) public var dataModel: RCCalendarDataModel {
        didSet {
            self.dataModelWasReloaded()
        }
    }

    private(set) public var isAuthenticating : Bool
    private(set) public var isAuthenticated: Bool

    // private stuff
    private let eventKitController: EKController
    private var needsNotify = false
    private let nextAlarmTimer: SimpleTimer
    
    public let dataModelStorage: DataModelStorage
    
    public init(withDataModelStorage dataModelStorage: DataModelStorage) {
        self.eventKitController = EKController(withDataModelStorage: dataModelStorage)
        self.dataModel = RCCalendarDataModel()
        self.isAuthenticating = false
        self.isAuthenticated = false
        self.nextAlarmTimer = SimpleTimer(withName: "NextAlarmTimer")
        self.dataModelStorage = dataModelStorage
    
        self.eventKitController.delegate = self
    }
    
    // MARK: Methods
    
    public func reloadData() {
        self.eventKitController.reloadDataModel()
    }
    
    public func update(calendar newCalendar: RCCalendar) {
        
        var newCalendarLookup: [CalendarID: RCCalendar] = [:]
        
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

            self.dataModel = RCCalendarDataModel(calendars: updatedCalendarList,
                                               delegateCalendars: updatedDelegateList,
                                               events: dataModel.events,
                                               reminders: dataModel.reminders)
            self.dataModelStorage.update(calendar: newCalendar)
            
            self.logger.log("RCCalendarDataModel: updated calendar: \(newCalendar.sourceTitle): \(newCalendar.title)")
            
            self.notify()

            self.reloadData()        }
    }

    public func update(event: RCEvent) {
        self.update(someEvents: [event])
    }
    
    public func update(someEvents: [RCEvent]) {

        if let updatedEvents = self.update(someItems: someEvents,
                                           inItems: self.dataModel.events) {
            
            updatedEvents.forEach {
                self.dataModelStorage.update(event: $0)
            }
            
            self.dataModel = RCCalendarDataModel(calendars: dataModel.calendars,
                                               delegateCalendars: dataModel.delegateCalendars,
                                               events: updatedEvents,
                                               reminders: dataModel.reminders)

            self.notify()
        }
    }
    
    public func update(reminder: RCReminder) {
        self.update(someReminders: [reminder] )
    }
    
    public func update(someReminders: [RCReminder]) {
        if let updatedReminders = self.update(someItems: someReminders,
                                              inItems: self.dataModel.reminders) {
            
            updatedReminders.forEach {
                self.dataModelStorage.update(reminder: $0)
            }
            
            self.dataModel = RCCalendarDataModel(calendars: dataModel.calendars,
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
    
    private func update<T>(someItems: [T], inItems: [T]) -> [T]? where T: RCCalendarItem {
        
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
    
    private func newCalendars(for newCalendar: RCCalendar,
                              calendarMap: [CalendarSource: [RCCalendar]],
                              newCalendarLookup: inout [CalendarID: RCCalendar] ) -> [CalendarSource: [RCCalendar]]? {
        
        var newCalendarMap: [CalendarSource: [RCCalendar]] = [:]
        
        var foundChange = false
        for (source, calendars) in calendarMap {
            var newCalendarList: [RCCalendar] = []
            
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
                NotificationCenter.default.post(name: RCCalendarDataModelController.DidChangeEvent, object: self)
            }
        }
    }
    
    // MARK: EKController delegate method
    
    func eventKitController(_ controller: EKController,
                            didReloadDataModel dataModel: RCCalendarDataModel) {
     
        self.dataModel = dataModel
        
        self.notify()
    }
    
    // MARK: Alarms
    
    public func stopAllAlarms() {
        if let updatedEvents = self.muteAlarms(forItems: Controllers.dataModelController.dataModel.events)  {
            self.update(someEvents: updatedEvents)
        }

        if let updatedReminders = self.muteAlarms(forItems: Controllers.dataModelController.dataModel.reminders) {
            self.update(someReminders: updatedReminders)
        }
    }
    
    private func muteAlarms<T>(forItems items: [T]) -> [T]? where T: RCCalendarItem {
        var outList:[T] = []
        var madeChange = false
        
        for item in items {
            
            var alarm = item.alarm
            
            if  alarm.isFiring {
                alarm.mutedDate = Date()
                
                var updatedItem = item
                updatedItem.alarm = alarm
                outList.append(updatedItem)
                
                madeChange = true
            } else {
                outList.append(item)
            }
        }
        
        return madeChange ? outList : nil
    }
    
    private func updateAlarms<T>(forItems items: [T]) -> [T]? where T: RCCalendarItem {
        var outList:[T] = []
        var madeChange = false
        
        for item in items {
            var alarm = item.alarm
            if alarm.updateState() {
                var updatedItem = item
                updatedItem.alarm = alarm
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
            self.logger.log("Updated alarms for \(updatedEvents.count) events")
        }
    
        if let updatedReminders = self.updateAlarms(forItems: self.dataModel.reminders) {
            self.update(someReminders: updatedReminders)
            self.logger.log("Updated alarms for \(updatedReminders.count) events")
        }
    }
    
    public func enableAllPersonalCalendars() {
        for (_, calendars) in self.dataModel.calendars {
            for calendar in calendars {
                var newCalendar = calendar
                newCalendar.isSubscribed = true
                self.update(calendar: newCalendar)
                self.logger.log("Enabled default calendar: \(calendar)")
            }
        }
    }
    
    private func dataModelWasReloaded() {
        self.updateAlarmsIfNeeded()
        self.startTimerForNextEventTime()
    }
    
    private func startTimerForNextEventTime() {
        self.nextAlarmTimer.stop()
        
        if let nextAlarmTime = Controllers.dataModelController.dataModel.nextAlarmDateForSchedulingTimer {
            self.logger.log("scheduling next alarm update for: \(nextAlarmTime.shortDateAndTimeString)")
            self.nextAlarmTimer.start(withDate: nextAlarmTime) { [weak self] (timer) in
                self?.logger.log("next alarm date timer did fire after: \(timer.timeInterval), scheduled for: \(nextAlarmTime.shortDateAndTimeString)")
                self?.reloadData()
            }
        }
    }

}

extension RCEvent {
    public func setAlarmMuted(_ isMuted: Bool) {
        var newAlarm = self.alarm
        newAlarm.mutedDate = isMuted ? Date() : nil
        
        var newEvent = self
        newEvent.alarm = newAlarm
        
        Controllers.dataModelController.update(event: newEvent)
    }
}

extension RCReminder {
    public func setAlarmMuted(_ isMuted: Bool) {
        var newAlarm = self.alarm
        newAlarm.mutedDate = isMuted ? Date() : nil

        var newReminder = self
        newReminder.alarm = newAlarm
        
        Controllers.dataModelController.update(reminder: newReminder)
    }
    
    public func snoozeAlarm() {
        var updatedAlarm = self.alarm
        updatedAlarm.snoozeInterval += 60 * 60 * 2
        
        var newReminder = self
        newReminder.alarm = updatedAlarm
        
        Controllers.dataModelController.update(reminder: newReminder)
    }
}

extension RCCalendar {
    public func set(subscribed: Bool) {
        var updatedCalendar = self
        updatedCalendar.isSubscribed = subscribed
        Controllers.dataModelController.update(calendar: updatedCalendar)
    }
}
