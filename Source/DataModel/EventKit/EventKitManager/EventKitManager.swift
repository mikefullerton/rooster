//
//  CalenderManager.swift
//  Rooster
//
//  Created by Mike Fullerton on 11/13/20.
//

import Foundation
import EventKit

protocol EventKitManagerDelegate: AnyObject {
    func eventKitManager(_ manager: EventKitManager,
                         didReloadDataModel dataModel: EventKitDataModel)
}

// needs to be class to recieve NSNotifications
class EventKitManager : Reloadable {
    
    weak var delegate: EventKitManagerDelegate?
    
    private let store: EKEventStore
    private var delegateEventStore: EKEventStore?
    private let preferences: Preferences
    private var dataModel: EventKitDataModel
    private var eventStoreReloader: Reloader?
    
    init(preferences: Preferences) {
        self.store = EKEventStore()
        self.delegateEventStore = nil
        self.preferences = preferences
        self.dataModel = EventKitDataModel()
    }

    public func reloadData() {
        DispatchQueue.main.async {
            self.reloadDataModel()
        }
    }
    
    private func reloadDataModel() {
        
        let previousDataModel = self.dataModel
        
        let intermediateModel = IntermediateModel(personalCalendarModel: EKDataModel(store: self.store),
                                                  delegateCalendarModel: EKDataModel(store: self.delegateEventStore),
                                                  previousEvents: previousDataModel.events)
        
//        let personalEKCalendars = self.findCalendars()
//
//        let delegateEKCalendars = self.findDelegateCalendars()
//
//        let ekPersonalEvents = self.findEvents(withEKCalendars: personalEKCalendars,
//                                               store: self.store)
//
//        let ekDelegateEvents = self.delegateEventStore != nil ?
//                                    self.findEvents(withEKCalendars: delegateEKCalendars,
//                                                    store:self.delegateEventStore!) : []
//
//        let ekEvents = ekPersonalEvents + ekDelegateEvents
//
//        let sortedEKEvents = ekEvents.sorted { (lhs, rhs) -> Bool in
//            return lhs.startDate.isBeforeDate(rhs.startDate)
//        }
//
//        let personalCalendars = self.createCalendars(withEKCalendars: personalEKCalendars)
//
//        let delegateCalendars = self.createCalendars(withEKCalendars: delegateEKCalendars)
//
//        let events = self.createEvents(fromEKEvents: sortedEKEvents,
//                                       calendars: personalCalendars,
//                                       delegateCalendars: delegateCalendars)
//
//        // create final data model collections
//
//        let finalEvents = self.merge(oldEvents: previousDataModel.events, withNewEvents: events)
//
//        let finalCalendars = self.groupedCalendars(fromCalendars: personalCalendars)
//
//        let finalDelegateCalendars = self.groupedCalendars(fromCalendars: delegateCalendars)
//
//        let finalReminders = self.findReminders()
//
        let dataModel = EventKitDataModel(withIntermediateModel: intermediateModel)
        
        self.dataModel = dataModel
        
        if let delegate = self.delegate {
            delegate.eventKitManager(self, didReloadDataModel: dataModel)
        }
    }
    
    private func handleAccessGranted() {
        
        AppDelegate.instance.appKitBundle?.requestPermissionToDelegateCalendars(for: self.store, completion: { (success, delegateEventStore, error) in
            DispatchQueue.main.async {
                if success && delegateEventStore != nil {
                    self.delegateEventStore = delegateEventStore!
                }
                
                self.eventStoreReloader = Reloader(withNotificationName:.EKEventStoreChanged,
                                                   for: self)
                
                self.reloadData()
            }
        })
    }
    
    private func handleAccessDenied(error: Error?) {
        
    }
        
    public func requestAccess(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        var count = 0
        var errorResults: [Error?] = [ nil, nil ]
        var successResults: [Bool] = [ false, false ]
        
        let completion = { (success: Bool, error: Error?) in
            
            count += 1
            
            if count == 1 {
                successResults[0] = success
                errorResults[0] = error
            } else {
                successResults[1] = success
                errorResults[1] = error
            
                DispatchQueue.main.async {
                    
                    if success {
                        self.handleAccessGranted()
                    } else {
                        self.handleAccessDenied(error: error)
                    }
                    
                    completion(success, error)
                }
            }
        }
        
        self.store.requestAccess(to: EKEntityType.event, completion: completion)
        self.store.requestAccess(to: EKEntityType.reminder, completion: completion)
        
    }
}

extension EventKitDataModel {
    init(withIntermediateModel model : EventKitManager.IntermediateModel) {
        self.init(calendars: model.personalCalendars,
                  delegateCalendars: model.delegateCalendars,
                  events: model.events,
                  reminders: model.reminders)
    }
}
