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
        Preferences.instance.update(event)
        self.reloadData()
        print("updated event: \(event)")
    }
    
    func update(_ calendar: EventKitCalendar) {
        Preferences.instance.update(calendar)
        self.reloadData()
        print("EventKitDataModel: updated calendar: \(calendar.sourceTitle): \(calendar.title)")
    }
    
    private func notify() {
        NotificationCenter.default.post(name: EventKitDataModelController.DidChangeEvent, object: self)
    }
    
    func replace(allEvents: [EventKitEvent]) {
        allEvents.forEach { Preferences.instance.update($0) }
        self.reloadData()
    }
    
    func update(someEvents: [EventKitEvent]) {

        someEvents.forEach {
            Preferences.instance.update($0)
            print("updated event: \($0)")
        }
        self.reloadData()
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
    func updatedEvent(didStartFiring: Bool,
                      isFiring: Bool,
                      hasFired: Bool) -> EventKitEvent {
        
        return EventKitEvent(withEvent: self.EKEvent,
                             calendar: self.calendar,
                             subscribed: self.isSubscribed,
                             didStartFiring: didStartFiring,
                             isFiring: isFiring,
                             hasFired: hasFired)
    }
    
    func stopAlarm() {
        
        let updatedEvent = self.updatedEvent(didStartFiring: true,
                                             isFiring: false,
                                             hasFired: true)
        
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
