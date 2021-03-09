//
//  EventKitDataModelController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation

public protocol EventKitDataModelControllerDelegate: AnyObject {
    func eventKitDataModelControllerNeedsReload(_ eventKitDataModelController: EventKitDataModelController)
}

/// interface the app uses to access or update the data model.
public class EventKitDataModelController: Loggable {
    // MARK: - public properties

    public weak var delegate: EventKitDataModelControllerDelegate?
    public var isAuthenticated: Bool {
        self.ekDataModelController.isAuthenticated
    }
    public var isOpen: Bool {
        self.ekDataModelController.isOpen
    }

    // MARK: - private properties

    private let ekDataModelController: EKDataModelController
    private let dataModelFactory = EventKitDataModelFactory()

    // MARK: - methods

    public init(withSchedulingQueue schedulingQueue: DispatchQueue) {
        self.ekDataModelController = EKDataModelController(withSchedulingQueue: schedulingQueue)
        self.ekDataModelController.delegate = self
    }

    public func reload(withRules rules: EKDataModelControllerRules,
                       completion: ((_ dataModel: EventKitDataModel) -> Void)? = nil) {
        self.logger.log("beginning datamodel reload...")

        assert(self.isAuthenticated, "not authenticated")
        assert(self.isOpen, "not open")

        guard self.isAuthenticated else {
            self.logger.error("not authenenticated")
            return
        }

        guard self.isOpen else {
            self.logger.error("not open open")
            return
        }

        self.ekDataModelController.reload(withRules: rules) { [weak self] ekDataModel in
            guard let self = self else { return }

            let dataModel = self.dataModelFactory.createDataModel(withEKDataModel: ekDataModel)

            self.logger.log("Reloaded data model ok: \(dataModel.shortDescription)")

            completion?(dataModel)
        }
    }

    public func open(withRules rules: EKDataModelControllerRules,
                     completion: ((_ dataModel: EventKitDataModel) -> Void)? = nil) {
        self.logger.log("beginning opening datamodel...")

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

        self.ekDataModelController.open(withRules: rules) { [weak self] ekDataModel in
            guard let self = self else { return }

            let dataModel = self.dataModelFactory.createDataModel(withEKDataModel: ekDataModel)

            self.logger.log("Opened data model ok ok: \(dataModel.shortDescription)")

            completion?(dataModel)
        }
    }

    public func requestAccessToCalendars(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        assert(!self.isAuthenticated, "already authenicated")

        guard self.ekDataModelController.isAuthenticated == false else {
            completion(false, nil)
            return
        }

        self.logger.log("starting to authenticate...")

        self.ekDataModelController.requestAccess { [weak self] success, error in
            guard let self = self else { return }

            guard success else {
                self.logger.error("failed to authenticate with error: \(String(describing: error))")
                completion(false, error)
                return
            }

            self.logger.log("authenticated ok!")

            completion(true, nil)
        }
    }
}

extension EventKitDataModelController: EKDataModelControllerDelegate {
    public func ekDataModelControllerNeedsReload(_ controller: EKDataModelController) {
        guard let delegate = self.delegate else {
            self.logger.error("received request to reload from ekDataModelController, delegate is nil!")
            return
        }

        self.logger.log("received request to reload from ekDataModelController, notifying delegate")
        delegate.eventKitDataModelControllerNeedsReload(self)
    }
}
