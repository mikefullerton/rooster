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

    private var disableSaving: Bool = false
    
    // public properties
    private(set) public var dataModel: RCCalendarDataModel? = nil {
        didSet {
            if oldValue != nil {
                if oldValue != self.dataModel {
                    self.saveDataModel()
                } else {
                    self.logger.log("no change in data model")
                }
            } else if self.dataModel != nil {
                self.notify()
            }
        }
    }

    private(set) public var isAuthenticating : Bool
    private(set) public var isAuthenticated: Bool

    // private stuff
    private let eventKitController: EKController
    private var needsNotify = false
    
    public let dataModelStorage: DataModelStorage
    
    public init(withDataModelStorage dataModelStorage: DataModelStorage) {
        self.eventKitController = EKController(withDataModelStorage: dataModelStorage)
        self.isAuthenticating = false
        self.isAuthenticated = false
        self.dataModelStorage = dataModelStorage
        self.eventKitController.delegate = self
    }
    
    // MARK: Methods
    
    private func saveDataModel() {
        self.logger.log("Saving data model")
        if let dataModel = self.dataModel {
            self.dataModelStorage.writeDateModel(dataModel) { success, error in
                
                // TODO: handle failure
                
                self.notify()
                self.reloadData()
            }
        }
    }
    
    public func readFromStorage(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        self.dataModelStorage.read(completion: completion)
    }
    
    public func reloadData() {
        self.eventKitController.reloadDataModel()
    }
    
    public func update(calendar newCalendar: RCCalendar) {
        
        var newCalendarLookup: [CalendarID: RCCalendar] = [:]
        
        if let dataModel = self.dataModel {
        
            let newCalendarList = self.newCalendars(for: newCalendar,
                                                    calendarMap: dataModel.calendars,
                                                    newCalendarLookup: &newCalendarLookup)

            let newDelegateCalendarList = self.newCalendars(for: newCalendar,
                                                            calendarMap: dataModel.delegateCalendars,
                                                            newCalendarLookup: &newCalendarLookup)
            
            if newCalendarList != nil || newDelegateCalendarList != nil {
                
                let updatedCalendarList = newCalendarList == nil ? dataModel.calendars : newCalendarList!
                let updatedDelegateList = newDelegateCalendarList == nil ? dataModel.delegateCalendars : newDelegateCalendarList!
                
                self.dataModel = RCCalendarDataModel(calendars: updatedCalendarList,
                                                     delegateCalendars: updatedDelegateList,
                                                     events: dataModel.events,
                                                     reminders: dataModel.reminders)
                
                self.logger.log("RCCalendarDataModel: updated calendar: \(newCalendar.sourceTitle): \(newCalendar.title)")
            }
        }
            
    }

    public func update(event: RCEvent) {
        self.update(someEvents: [event])
    }
    
    public func update(someEvents: [RCEvent]) {

        if let dataModel = self.dataModel,
            let updatedEvents = self.merge(someItems: someEvents,
                                           inItems: dataModel.events) {
            
            self.dataModel = RCCalendarDataModel(calendars: dataModel.calendars,
                                                  delegateCalendars: dataModel.delegateCalendars,
                                                  events: updatedEvents,
                                                  reminders: dataModel.reminders)
        }
    }
    
    public func update(reminder: RCReminder) {
        self.update(someReminders: [reminder] )
    }
    
    public func update(someReminders: [RCReminder]) {
        if  let dataModel = self.dataModel,
            let updatedReminders = self.merge(someItems: someReminders,
                                              inItems: dataModel.reminders) {
        
            self.dataModel = RCCalendarDataModel(calendars: dataModel.calendars,
                                                 delegateCalendars: dataModel.delegateCalendars,
                                                 events: dataModel.events,
                                                 reminders: updatedReminders)
        }
    }
    
    public func update(calendarItem: RCCalendarItem) {
        if let event = calendarItem as? RCEvent {
            self.update(event: event)
        } else if let reminder = calendarItem as? RCReminder {
            self.update(reminder: reminder)
        }
    }
    
    public func requestAccessToCalendars(_ completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        self.isAuthenticating = true
        self.eventKitController.requestAccess { (success, error) in
            DispatchQueue.main.async {
                self.isAuthenticating = false
                if success {
                    self.isAuthenticated = true
                }
                
                completion(success, error)
            }
        }
    }
    
    // MARK: private implementation
    
    private func merge<T>(someItems: [T], inItems: [T]) -> [T]? where T: RCCalendarItem, T: Equatable {
        
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
    }
    
    // MARK: Alarms
    public func enableAllPersonalCalendars() {
        if let dataModel = self.dataModel {
            var newCalendars: [CalendarSource: [RCCalendar]] = [:]
            
            for (source, calendars) in dataModel.calendars {
                
                newCalendars[source] = calendars.map {
                    var calendar = $0
                    calendar.isSubscribed = true
                    self.logger.log("Enabled default calendar: \(calendar.description)")
                    
                    return calendar
                }
                
            }
        
            
            self.dataModel = RCCalendarDataModel(calendars: newCalendars,
                                                 delegateCalendars: dataModel.delegateCalendars,
                                                 events: dataModel.events,
                                                 reminders: dataModel.reminders)
        }
    }
}

extension RCCalendar {
    public func set(subscribed: Bool) {
        var updatedCalendar = self
        updatedCalendar.isSubscribed = subscribed
        Controllers.dataModelController.update(calendar: updatedCalendar)
    }
}
