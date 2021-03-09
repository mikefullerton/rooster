//
//  CalenderManager.swift
//  Rooster
//
//  Created by Mike Fullerton on 11/13/20.
//

import Foundation
import EventKit

public protocol EKControllerDelegate: AnyObject {
    func eventKitController(_ controller: EKController,
                            didReloadDataModel dataModel: RCCalendarDataModel)
}

// Highest level controller for creating and updating the RCCalendarDataModel
public class EKController: Loggable {
    
    public weak var delegate: EKControllerDelegate?
    
    public let store: EKEventStore
    public private(set) var delegateEventStore: EKEventStore?
    public private(set) var isOpen = false
    public private(set) var isAuthenticated = false
    
    private(set) var dataModel: RCCalendarDataModel {
        didSet {
            if self.isOpen && oldValue != self.dataModel {
                self.logger.log("did reload dataModel, notifying delegate")
                self.delegate?.eventKitController(self, didReloadDataModel: self.dataModel)
            }
        }
    }
    
    private var reloadScheduler = EKControllerReloadScheduler()
    public let dataModelStorage: DataModelStorage
    
    public var settings = EKDataModelSettings.default {
        didSet {
            if self.isOpen && oldValue != self.settings {
                self.logger.log("Data model settings were changed, reloading")
                self.reloadDataModel()
            }
        }
    }
    
    public init(withDataModelStorage dataModelStorage: DataModelStorage) {
        self.dataModelStorage = dataModelStorage
        self.store = EKEventStore()
        self.delegateEventStore = nil
        self.dataModel = RCCalendarDataModel()
    }
    
    public func reloadDataModel() {
        
        precondition(self.isAuthenticated, "not authenticated")
        precondition(self.isOpen, "not authenticated")
        
        guard self.isAuthenticated else {
            self.logger.error("not authenticated -- ignoring request to reloadDataModel")
            return
        }
        
        guard self.isOpen else {
            self.logger.error("not open -- ignoring request to reloadDataModel")
            return
        }
        
        self.reloadScheduler.requestReload(forController: self) { dataModel in
            self.dataModel = dataModel
        }
    }
        
    @objc func notificationReceived(_ notif: NSNotification) {
        self.logger.log("reload event received from event Store: \(notif)")
        self.reloadDataModel()
    }
    
    private func registerForEvents() {
        
        precondition(self.isOpen, "not open!")
        
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
    
    private var authenticator: EKEventStoreAuthenticator?
    
    public func requestAccess(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        self.logger.log("requesting access to events and reminders in user eventStore: \(self.store.eventStoreIdentifier)")
        
        let authenticator = EKEventStoreAuthenticator()
        authenticator.requestAccess(toEventStore: self.store) { success, delegateEventStore, error in
            DispatchQueue.main.async {
                if success {
                    if delegateEventStore != nil {
                        self.delegateEventStore = delegateEventStore!
                        self.logger.log("did load delegateEventStore")
                    } else {
                        self.logger.log("delegate event store not loaded")
                    }
                    
                    self.logger.log("finished requesting access to EventKit calendars with success")
                    
                    self.isAuthenticated = true
                } else {
                    self.logger.error("failed to authenticate to event stores.)")
                }
            
                completion(success, error)

                self.authenticator = nil
            }
        }
    }
    
    public func openDataModel(withSettings settings: EKDataModelSettings,
                              completion:@escaping (_ dataModel: RCCalendarDataModel) -> Void) {
        
        precondition(self.isAuthenticated, "not authenticated!")
        precondition(!self.isOpen, "already open!")
        
        guard self.isAuthenticated else {
            self.logger.error("not authenticated!")
            return
        }
        
        guard self.isOpen == false else {
            self.logger.error("already open!")
            return
        }
        
        self.settings = settings
        
        self.reloadScheduler.requestReload(forController: self) { dataModel in
            self.isOpen = true
            self.registerForEvents()
            self.dataModel = dataModel
            
            completion(dataModel)
        }
    }
}

