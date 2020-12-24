//
//  CalenderManager.swift
//  Rooster
//
//  Created by Mike Fullerton on 11/13/20.
//

import Foundation
import EventKit

protocol EventKitControllerDelegate: AnyObject {
    func eventKitController(_ controller: EventKitController,
                            didReloadDataModel dataModel: EventKitDataModel)
}

// Highest level controller for creating and updating the EventKitDataModel
class EventKitController: Loggable {
    
    weak var delegate: EventKitControllerDelegate?
    
    private let store: EKEventStore
    private var delegateEventStore: EKEventStore?
    private var dataModel: EventKitDataModel
    private var eventStoreReloader: Reloader?
    private var reloadingState: ReloadingState {
        didSet {
            self.logger.log("state changed: \(self.reloadingState.description)")
        }
    }
    private var authenticated: Bool
    
    init() {
        self.store = EKEventStore()
        self.delegateEventStore = nil
        self.dataModel = EventKitDataModel()
        self.reloadingState = ReloadingState()
        self.authenticated = false
    }
    
    public func reloadDataModel() {
        if !self.authenticated {
            self.logger.log("not authenticated -- ignoring request to reloadDataModel")
            return
        }
        self.requestReload()
    }
    
    private func startReloadIfNeeded() {
        if !self.reloadingState.needsReload {
            self.logger.log("done reloading")
        } else if self.reloadingState.canStartReload {
            self.logger.log("Starting reload")
            self.reloadingState = self.reloadingState.reloadingStarted
            self.actuallyReloadDataModel()
        } else {
            self.logger.log("defering reload request during reload")
        }
    }
    
    private func requestReload() {
        DispatchQueue.main.async {
            self.reloadingState = self.reloadingState.requestReload
            self.startReloadIfNeeded()
        }
    }
    
    private func reloadIfNeeded() {
        DispatchQueue.main.async {
            self.startReloadIfNeeded()
        }
    }
    
    private func actuallyReloadDataModel() {
        self.fetchNewDataModel(forUserStore: self.store,
                               delegateEventStore: self.delegateEventStore,
                               previousDataModel: self.dataModel) { (newDataModel) in
            
            self.logger.log("did receive new dataModel")
            
            self.dataModel = newDataModel
            
            self.logger.log("did reload dataModel, notifying delegate")
            
            if let delegate = self.delegate {
                delegate.eventKitController(self, didReloadDataModel: self.dataModel)
            }
            
            self.reloadingState = self.reloadingState.reloadingFinished
            
            self.reloadIfNeeded()
        }
    }
    
    @objc func notificationReceived(_ notif: NSNotification) {
        self.logger.log("reload event received from event Store: \(notif)")
        self.reloadDataModel()
    }
    
    private func registerForEvents() {
        
        self.logger.log("registered for events from EventStore")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationReceived(_:)),
                                               name: .EKEventStoreChanged,
                                               object: self.store)
        
        if let delegateStore = self.delegateEventStore {
            self.logger.log("registered for events from delegate EventStore")
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(notificationReceived(_:)),
                                                   name: .EKEventStoreChanged,
                                                   object: delegateStore)
        }
    }
    
    private func finishedRequestingAccessToEventStores(success: Bool,
                                                       delegateEventStore: EKEventStore?,
                                                       error: Error?,
                                                       completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        DispatchQueue.main.async {
            if success {
                if delegateEventStore != nil {
                    self.delegateEventStore = delegateEventStore!
                    self.logger.log("did load delegateEventStore")
                } else {
                    self.logger.log("delegate event store not loaded")
                }
                
                self.logger.log("finished requesting access to EventKit calendars with success")
                
                self.registerForEvents()
                self.authenticated = true
                self.actuallyReloadDataModel()
            } else {
                self.logger.error("failed to authenticate to event stores.)")
            }
        
            completion(success, error)

        }
    }
    
    private func requestAccessToDelegateStore(withUserStore store: EKEventStore,
                                              completion: @escaping (_ success: Bool, _ eventStore: EKEventStore?, _ error: Error?) -> Void) {
        
        #if targetEnvironment(macCatalyst)
        AppKitPluginController.instance.eventKitHelper.requestPermissionToDelegateCalendars(for: self.store, completion: completion)
        #else
        self.logger.log("Delegate eventStore not available on iOS");
        
        completion(true, nil, nil)
        
        #if false
        
        // sigh, can't get delegate calendars on iOS
        
        let sources = store.delegateSources

        let delegateEventStore = EKEventStore(sources: sources)

        self.logger.log("EventKitHelper requesting access to delegate calendars")
        
        delegateEventStore.requestAccess(to: EKEntityType.event) { (success, error) in
            if success == false || error != nil {
                self.logger.error("Failed to be granted access to delegate calendars with error: \(error?.localizedDescription ?? "nil")")
                completion!(false, nil, error)
            } else {
                self.logger.log("Access granted to delegate calendars")
                completion!(true, delegateEventStore, nil)
            }
        }
        #endif
        
        #endif
    }
    
    private func fasterRequestAccess(toStore store: EKEventStore, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
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
            
                completion(success, error)
            }
        }
        
        store.requestAccess(to: EKEntityType.event, completion: completion)
        store.requestAccess(to: EKEntityType.reminder, completion: completion)
    }
    
    private func requestAccess(toStore store: EKEventStore, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
    
        self.logger.log("requesting access to events in eventStore: \(store.eventStoreIdentifier)")
        store.requestAccess(to: EKEntityType.event) { success, error in
            if success {
                self.logger.log("granted access to events in user eventStore, requesting access to reminders in eventStore: \(store.eventStoreIdentifier)")
                
                store.requestAccess(to: EKEntityType.reminder) { success, error in

                    if success {
                        self.logger.log("granted access to reminders in eventStore: \(store.eventStoreIdentifier)")
                    }
                    
                    completion(success, error)
                }
            } else {
                
                self.logger.error("failed to be granted access to store: \(store.eventStoreIdentifier) with error: \(error?.localizedDescription ?? "nil")")
                
                completion(success, error)
            }
        }
    }
    
    public func requestAccess(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        self.logger.log("requesting access to events and reminders in user eventStore: \(self.store.eventStoreIdentifier)")
        
        self.requestAccess(toStore: self.store) { success, error in
            if success {
                self.requestAccessToDelegateStore(withUserStore: self.store) { success, delegateEventStore, error in
                    
                    if !success || error != nil{
                        self.logger.error("failed to be granted access to delegate eventStore with error: \(error?.localizedDescription ?? "nil")")
                    }
                    
                    self.finishedRequestingAccessToEventStores(success: success,
                                                               delegateEventStore: delegateEventStore,
                                                               error: error,
                                                               completion: completion)
                    
                }
            } else {
                self.logger.error("failed to be granted access to user eventStore: \(self.store.eventStoreIdentifier) with error: \(error?.localizedDescription ?? "nil")")

                self.finishedRequestingAccessToEventStores(success: success,
                                                           delegateEventStore: nil,
                                                           error: error,
                                                           completion: completion)
            }
        }
        
    }
}


