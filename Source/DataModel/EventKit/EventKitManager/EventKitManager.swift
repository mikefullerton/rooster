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
    private var needsReload: Bool
    
    init(preferences: Preferences) {
        self.store = EKEventStore()
        self.delegateEventStore = nil
        self.preferences = preferences
        self.dataModel = EventKitDataModel()
        self.needsReload = false
    }

    func reloadData() {
        print("EventKitManager asked to reloadData")
        self.reloadDataModel()
    }
    
    public func reloadDataModel() {
        print("EventKitManager asked to reloadDataModel")
        self.needsReload = true
        DispatchQueue.main.async {
            if self.needsReload {
                self.needsReload = false
                self.actuallyReloadDataModel()
            }
        }
    }
    
    private func actuallyReloadDataModel() {
        
        let previousDataModel = self.dataModel
        
        let intermediateModel = IntermediateModel(personalCalendarModel: EKDataModel(store: self.store),
                                                  delegateCalendarModel: EKDataModel(store: self.delegateEventStore),
                                                  previousEvents: previousDataModel.events)
        
        let dataModel = EventKitDataModel(withIntermediateModel: intermediateModel)
        
        self.dataModel = dataModel
        
        print("EventKitManager did reload dataModel")
        
        if let delegate = self.delegate {
            delegate.eventKitManager(self, didReloadDataModel: dataModel)
        }
    }
    
    @objc func notificationReceived(_ notif: NSNotification) {
        print("reload event received from event Store: \(notif)")
        self.reloadDataModel()
    }
    
    private func registerForEvents() {
        
        print("registered for events from EventStore")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationReceived(_:)),
                                               name: .EKEventStoreChanged,
                                               object: self.store)
        
        if let delegateStore = self.delegateEventStore {
            print("registered for events from delegate EventStore")
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(notificationReceived(_:)),
                                                   name: .EKEventStoreChanged,
                                                   object: delegateStore)
        }
 }
    
    
    private func handleAccessGranted() {
        
        AppDelegate.instance.appKitBundle?.requestPermissionToDelegateCalendars(for: self.store, completion: { (success, delegateEventStore, error) in
            DispatchQueue.main.async {
                if success && delegateEventStore != nil {
                    self.delegateEventStore = delegateEventStore!
                }
                print("EventKitManager did authenticate: \(success), error: \(String(describing: error))")
                
                self.registerForEvents()
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
