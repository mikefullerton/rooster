//
//  CalenderManager.swift
//  Rooster
//
//  Created by Mike Fullerton on 11/13/20.
//

import EventKit
import Foundation

public protocol EKDataModelControllerDelegate: AnyObject {
    func ekDataModelControllerNeedsReload(_ controller: EKDataModelController)
}

public protocol EKDataModelControllerRules {
    var dateRange: DateRange { get }

    var enabledCalendars: Set<String> { get }

    var enabledDelegateCalendars: Set<String> { get }

    func isCalendarEnabled(calendarID: String) -> Bool

    func isDelegateCalendarEnabled(calendarID: String) -> Bool
}

// Highest level controller for creating and updating the EventKitDataModel
public class EKDataModelController: Loggable {
    public weak var delegate: EKDataModelControllerDelegate?

    public let store: EKEventStore

    public private(set) var delegateEventStore: EKEventStore?

    public private(set) var isAuthenticated = false

    public private(set) var isOpen = false

    private var authenticator: EKEventStore.Authenticator?

    private lazy var dataModelFetcher = DataModelFetcher(withController: self,
                                                         schedulingQueue: self.schedulingQueue)

    private let schedulingQueue: DispatchQueue

    public init(withSchedulingQueue schedulingQueue: DispatchQueue) {
        self.schedulingQueue = schedulingQueue
        self.store = EKEventStore()
        self.delegateEventStore = nil
    }

    public func reload(withRules rules: EKDataModelControllerRules, completion: @escaping (_ dataModel: EKDataModel) -> Void) {
        assert(self.isAuthenticated, "not authenticated")
        assert(self.isOpen, "not authenticated")

        guard self.isAuthenticated else {
            self.logger.error("not authenenticated")
            return
        }

        guard self.isOpen else {
            self.logger.error("not open open")
            return
        }

        self.logger.log("""
            loading events and reminders for dates: \(rules.dateRange.description), \
            \(rules.enabledCalendars.count) calendars, \
            \(rules.enabledDelegateCalendars.count) delegate calendars
            """)

        self.dataModelFetcher.fetch(withRules: rules) { [weak self] dataModel in
            guard let self = self else { return }

            self.logger.log("received new data model from reloadScheduler: \(dataModel.description)")

            completion(dataModel)
        }
    }

    public func open(withRules rules: EKDataModelControllerRules, completion: @escaping (_ dataModel: EKDataModel) -> Void) {
        assert(self.isAuthenticated, "not authenticated")
        assert(!self.isOpen, "not authenticated")

        guard self.isAuthenticated else {
            self.logger.error("not authenticated -- ignoring request to reload")
            return
        }

        guard !self.isOpen else {
            self.logger.error("already open")
            return
        }

        self.isOpen = true
        self.registerForEvents()

        self.reload(withRules: rules, completion: completion)
    }

    @objc func notificationReceived(_ notif: Notification) {
        self.logger.log("reload event received from event Store: \(notif)")
        self.delegate?.ekDataModelControllerNeedsReload(self)
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

    public func requestAccess(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        self.logger.log("requesting access to events and reminders in user eventStore: \(self.store.eventStoreIdentifier)")

        self.authenticator = EKEventStore.Authenticator()

        self.authenticator?.requestAccess(toEventStore: self.store) { [weak self] success, delegateEventStore, error in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

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

                self.authenticator = nil

                completion(success, error)
            }
        }
    }
}
