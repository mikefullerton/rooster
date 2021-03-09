//
//  AlarmNotification.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation

public protocol AlarmNotificationDelegate : AnyObject {
    func alarmNotificationDidStart(_ alarmNotification: AlarmNotification)
    func alarmNotificationDidFinish(_ alarmNotification: AlarmNotification)
    func alarmNotification(_ alarmNotification: AlarmNotification, didUpdateState state: AlarmNotificationController.AlarmState)
}

public class AlarmNotification: Equatable, Hashable, Loggable, CustomStringConvertible, Identifiable {
    
    public var alarmState: AlarmNotificationController.AlarmState = .zero

    
    public weak var delegate : AlarmNotificationDelegate?
    
    public let id: String
    public private(set) var itemID: String
    
    private static var idCounter:Int = 0
    
    private var alarmNotificationActions: [AlarmNotificationAction] = []
    
    deinit {
        self.didStop()
    }
    
    public var calendarItem: RCCalendarItem? {
        if  let dataModel = Controllers.dataModel.dataModel {
            return dataModel.item(forIdentifier: self.itemID)
        }
        
        return nil
    }
    
    public static var actionsFactoryBlock: () -> [AlarmNotificationAction] = {
        return []
    }
    
    public func createActions() -> [AlarmNotificationAction] {
        return Self.actionsFactoryBlock()
    }
    
    public init(withItemIdentifier itemIdentifier: String, alarmState: AlarmNotificationController.AlarmState) {
        AlarmNotification.idCounter += 1

        self.id = "\(AlarmNotification.idCounter)"
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

        if let delegate = self.delegate {
            delegate.alarmNotificationDidStart(self)
        }
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
        self.alarmNotificationActions = []
        
        if var calendarItem = self.calendarItem,
            !calendarItem.alarm.isFinished {
            calendarItem.alarm.isFinished = true
                
            Controllers.dataModel.update(calendarItem: calendarItem)
        }
        
        if let delegate = self.delegate {
            delegate.alarmNotificationDidFinish(self)
        }
        
        self.alarmState += [ .finished ]
        
    }
    
    func actionDidFinish(_ action: AlarmNotificationAction) {
        // TODO:???
    }
    
    public static func == (lhs: AlarmNotification, rhs: AlarmNotification) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    public var description: String {
        return "\(type(of:self)): \(self.id), itemID: \(self.itemID), alarmState: \(self.alarmState.description)"
    }
    
    public func shouldStop(ifNotContainedIn dataModelIdentifiers: Set<String>) -> Bool {
        return !dataModelIdentifiers.contains(itemID)
    }
    
    public func bringLocationAppsForward() {
        if let item = self.calendarItem {
            item.bringLocationAppsToFront()
        }
    }
}


