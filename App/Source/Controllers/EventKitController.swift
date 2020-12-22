//
//  CalenderManager.swift
//  Rooster
//
//  Created by Mike Fullerton on 11/13/20.
//

import Foundation
import EventKit
import OSLog

protocol EventKitControllerDelegate: AnyObject {
    func eventKitController(_ controller: EventKitController,
                            didReloadDataModel dataModel: EventKitDataModel)
}

// needs to be class to recieve NSNotifications
class EventKitController {
    
    static let logger = Logger(subsystem: "com.apple.rooster", category: "EventKitController")
    
    var logger: Logger {
        return EventKitController.logger
    }
    
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
    
    private func handleAccessGranted() {
        self.logger.log("granted access to EventKit to user calendars, now checking delegate calendars...")

        AppKitPluginController.instance.eventKitHelper.requestPermissionToDelegateCalendars(for: self.store, completion: { (success, delegateEventStore, error) in
            DispatchQueue.main.async {
                if success && delegateEventStore != nil {
                    self.delegateEventStore = delegateEventStore!
                    self.logger.log("did load delegateEventStore")
                }
                
                if success {
                    self.logger.log("did authenticate for all EventKit calendars")

                    self.registerForEvents()
                    self.authenticated = true
                    self.reloadDataModel()
                } else {
                    self.logger.fault("failed to authenticate with error: \(error?.localizedDescription ?? "nil" )")
                }

            }
        })
    }
    
    private func handleAccessDenied(error: Error?) {
        self.logger.error("failed to be granted access with error: \(error?.localizedDescription ?? "nil")")
    }
        
    public func requestAccess(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        self.logger.log("requesting access to events and reminders in user calanders")
        
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


