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
class EventKitManager {
    
    struct ReloadingState {
        private var requestID: Int
        private(set) var requestedCount : Int
        private(set) var reloading: Bool
        
        init() {
            self.init(requestedCount: 0, reloading: false, requestID: 0)
        }
        
        private init(requestedCount: Int, reloading: Bool, requestID: Int) {
            self.requestedCount = requestedCount
            self.reloading = reloading
            self.requestID = requestID
        }
        
        var needsReload: Bool {
            return self.requestedCount > 0
        }
        
        var canStartReload: Bool {
            return self.requestedCount > 0 && !self.reloading
        }
        
        var requestReload: ReloadingState {
            return ReloadingState(requestedCount: self.requestedCount + 1, reloading: self.reloading, requestID: self.requestID + 1)
        }

        var reloadingStarted: ReloadingState {
            return ReloadingState(requestedCount: 0, reloading: true, requestID: self.requestID + 1)
        }

        var reloadingFinished:ReloadingState {
            return ReloadingState(requestedCount: self.requestedCount, reloading: false, requestID: self.requestID + 1)
        }
        
        var description: String {
            return "ReloadingState: ID: \(self.requestID), requestedCount: \(self.requestedCount), reloading: \(self.reloading)"
        }

    }
    
    weak var delegate: EventKitManagerDelegate?
    
    private let store: EKEventStore
    private var delegateEventStore: EKEventStore?
    private let preferences: Preferences
    private var dataModel: EventKitDataModel
    private var eventStoreReloader: Reloader?
    private var reloadingState: ReloadingState {
        didSet {
            print("EventKitManager state changed: \(self.reloadingState.description)")
        }
    }
    private var authenticated: Bool
    
    init(preferences: Preferences) {
        self.store = EKEventStore()
        self.delegateEventStore = nil
        self.preferences = preferences
        self.dataModel = EventKitDataModel()
        self.reloadingState = ReloadingState()
        self.authenticated = false
    }
    
    public func reloadDataModel() {
        if !self.authenticated {
            print("EventKitManager not authenticated -- ignoring request to reloadDataModel ")
            return
        }
        self.requestReload()
    }
    
    private func startReloadIfNeeded() {
        if !self.reloadingState.needsReload {
            print("EventKitManager done reloading")
        } else if self.reloadingState.canStartReload {
            print("EventKitManager Starting reload")
            self.reloadingState = self.reloadingState.reloadingStarted
            self.actuallyReloadDataModel()
        } else {
            print("EventKitManager defering reload request during reload")
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
    
    private func handleIntermediateDataModelFetched(calendarDataModel: EKDataModel,
                                                    delegateCalendarModel: EKDataModel,
                                                    completion: @escaping (_ intermediateModel: IntermediateModel)-> Void) {
        
        DispatchQueue.main.async {
            let intermediateModel = IntermediateModel(personalCalendarModel: calendarDataModel,
                                                      delegateCalendarModel: delegateCalendarModel,
                                                      previousDataModel: self.dataModel)

            completion(intermediateModel)
        }

    }
    
    private func removeDuplicateDelegateCalendars(calendars: [EKCalendar],
                                                  delegateCalendars: [EKCalendar]) -> [EKCalendar] {
        
        var outDelegateCalendars: [EKCalendar] = []
        
        for delegateCalendar in delegateCalendars {
            var found = false
            calendars.forEach { (calendar) in
                if  calendar.uniqueID == delegateCalendar.uniqueID {
                    found = true
                    print("found duplicate calendar: \(delegateCalendar), \(delegateCalendar.uniqueID)")
                }
            }
            
            if !found {
                outDelegateCalendars.append(delegateCalendar)
            }
            
        }
        
        return outDelegateCalendars
    }
    
    
    private func fetchIntermediateDataModel(completion: @escaping (_ intermediateModel: IntermediateModel)-> Void) {
        
        let storeHelper = EKDataStoreHelper(store: self.store)
        let calendars = storeHelper.fetchCalendars()
        
        let delegateStoreHelper = EKDataStoreHelper(store: self.delegateEventStore)
        let delegateCalendars = self.removeDuplicateDelegateCalendars(calendars: calendars,
                                                                      delegateCalendars: delegateStoreHelper.fetchCalendars())
        
        var calendarDataModel: EKDataModel? = nil
        var delegateDataModel: EKDataModel? = nil
        
        storeHelper.fetchDataModel(withCalendars: calendars) { (dataModel) in
            calendarDataModel = dataModel
            
            print("EventKitManager received calendar model")
            
            if delegateDataModel != nil {
                self.handleIntermediateDataModelFetched(calendarDataModel: calendarDataModel!,
                                                        delegateCalendarModel: delegateDataModel!,
                                                        completion: completion)
            }
        }

        delegateStoreHelper.fetchDataModel(withCalendars: delegateCalendars) { (dataModel) in
            delegateDataModel = dataModel

            print("EventKitManager received delegate calendar model")

            if calendarDataModel != nil {
                self.handleIntermediateDataModelFetched(calendarDataModel: calendarDataModel!,
                                                        delegateCalendarModel: delegateDataModel!,
                                                        completion: completion)
            }
        }
    }
    
    private func actuallyReloadDataModel() {
        
        self.fetchIntermediateDataModel { (intermediateModel) in
            
            print("EventKitManager did receive intermediate dataModel")
            
            let dataModel = EventKitDataModel(withIntermediateModel: intermediateModel)
            
            self.dataModel = dataModel
            
            print("EventKitManager did reload dataModel, notifying delegate")
            
            if let delegate = self.delegate {
                delegate.eventKitManager(self, didReloadDataModel: dataModel)
            }
            
            self.reloadingState = self.reloadingState.reloadingFinished
            
            self.reloadIfNeeded()
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
                self.authenticated = true
                self.reloadDataModel()
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
