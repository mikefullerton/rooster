//
//  AlarmNotification.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation

public protocol AlarmNotificationDelegate: AnyObject {
    func alarmNotificationDidStart(_ alarmNotification: AlarmNotification)
    func alarmNotificationDidFinish(_ alarmNotification: AlarmNotification)
    func alarmNotification(_ alarmNotification: AlarmNotification, didUpdateState state: AlarmNotificationController.AlarmState)
}

public class AlarmNotification: Equatable, Hashable, Loggable, CustomStringConvertible {
    public var alarmState: AlarmNotificationController.AlarmState = .zero {
        didSet {
            if oldValue != self.alarmState {
                self.delegate?.alarmNotification(self, didUpdateState: self.alarmState)
            }
        }
    }

    public weak var delegate: AlarmNotificationDelegate?

    public private(set) var itemID: String

    private var alarmNotificationActions: [AlarmNotificationAction] = []

    deinit {
        self.didStop()
    }

    public var isFiring: Bool {
        self.alarmState.contains(.started) && !self.alarmState.contains(.finished )
    }

    public var scheduleItem: ScheduleItem? {
        CoreControllers.shared.scheduleController.schedule.scheduleItem(forID: self.itemID)
    }

    public static var actionsFactoryBlock: () -> [AlarmNotificationAction] = {
        []
    }

    public func createActions() -> [AlarmNotificationAction] {
        Self.actionsFactoryBlock()
    }

    public init(withItemIdentifier itemIdentifier: String, alarmState: AlarmNotificationController.AlarmState) {
        self.alarmState = alarmState
        self.itemID = itemIdentifier
    }

    private func performStartActions() {
        self.alarmNotificationActions.forEach { action in
            self.logger.log("Performing alarm action: \(action.description)")
            action.willStartAction(withItemID: itemID, alarmNotification: self)
            action.startAction()
        }
    }

    private func performStopActions() {
        self.alarmNotificationActions.forEach { action in
            action.stopAction()
            self.logger.log("Stopped alarm action: \(action.description)")
        }
        self.alarmNotificationActions = []
    }

    public func start() {
        guard !self.alarmState.contains(.started) else {
            self.logger.error("alarm already started: \(self.description)")
            return
        }

        self.alarmState = .started

        self.alarmNotificationActions = self.createActions()

        self.logger.log("starting alarm for \(self.description)")

        self.performStartActions()

        self.delegate?.alarmNotificationDidStart(self)
    }

    public func finish() {
        guard !self.alarmState.contains(.finished) else {
            self.logger.error("alarm already finished: \(self.description)")
            return
        }

        self.alarmState += .finished
        self.logger.log("finished alarm for \(self.description)")
        self.didStop()
    }

    public func stop() {
        self.alarmState += .aborted
        self.logger.log("stopping alarm for \(self.description)")
        self.didStop()
    }

    private func didStop() {
        self.performStopActions()
        self.alarmState += [ .finished ]
        self.delegate?.alarmNotificationDidFinish(self)
    }

    func actionDidFinish(_ action: AlarmNotificationAction) {
    }

    public static func == (lhs: AlarmNotification, rhs: AlarmNotification) -> Bool {
        lhs.itemID == rhs.itemID
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.itemID)
    }

    public var description: String {
        "\(type(of: self)): itemID: \(self.itemID), alarmState: \(self.alarmState.description)"
    }

    public func bringLocationAppsForward() {
        if let item = self.scheduleItem {
            item.bringLocationAppsToFront()
        }
    }
}
