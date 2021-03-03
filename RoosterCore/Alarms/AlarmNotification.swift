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
}

public protocol AlarmNotificationStartAction {
    func alarmNotificationStartAction(_ alarmNotification: AlarmNotification)
    func alarmNotificationStopAction(_ alarmNotification: AlarmNotification)
}

public class AlarmNotification: Equatable, Hashable, Loggable, CustomStringConvertible, SoundDelegate, Identifiable {
    
    enum State: String {
        case none = "None"
        case starting = "Starting"
        case started = "Started"
        case finished = "Finished"
        case aborted = "Aborted"
    }
    
    public weak var delegate : AlarmNotificationDelegate?
    
    private var state: State
    
    public let id: String
    public let itemID: String
    
    private static var idCounter:Int = 0
    
    private var startActions: [AlarmNotificationStartAction] = []
    
    deinit {
        self.performStopActions()
    }
    
    public static var startActionsFactory: () -> [AlarmNotificationStartAction] = {
        return []
    }
    
    public init(withItemIdentifier itemIdentifier: String) {
        AlarmNotification.idCounter += 1

        self.id = "\(AlarmNotification.idCounter)"
        self.state = .none
        self.itemID = itemIdentifier
    }
   
    public var item: RCCalendarItem? {
        let dataModel = Controllers.dataModelController.dataModel
        return dataModel.item(forIdentifier: self.itemID)
    }
    
    private func performStartActions() {
       self.startActions.forEach { $0.alarmNotificationStartAction(self) }
    }

    private func performStopActions() {
       self.startActions.forEach { $0.alarmNotificationStopAction(self) }
    }

    public func start() {
        
        self.startActions = Self.startActionsFactory()
        
        self.state = .starting
        self.logger.log("starting alarm for \(self.description)")

        self.performStartActions()
        
        self.state = .started

        if let delegate = self.delegate {
            delegate.alarmNotificationDidStart(self)
        }
    }
    
    public func stop() {
        self.logger.log("stopping alarm for \(self.description)")
        self.state = .aborted
        
        self.performStopActions()
    
        self.startActions = []
        
        if let delegate = self.delegate {
            delegate.alarmNotificationDidFinish(self)
        }
    }
    
    public static func == (lhs: AlarmNotification, rhs: AlarmNotification) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    public var description: String {
        return "\(type(of:self)): \(self.id), itemID: \(self.itemID), state: \(self.state.rawValue)"
    }
    
    public func soundWillStartPlaying(_ sound: SoundPlayerProtocol) {
    }
    
    public func soundDidStartPlaying(_ sound: SoundPlayerProtocol) {
    }

    public func soundDidUpdate(_ sound: SoundPlayerProtocol) {
    }

    public func soundDidStopPlaying(_ sound: SoundPlayerProtocol) {
        self.logger.log("alarm stopped playing sound: \(self.description)")
        self.state = .finished
        if let delegate = self.delegate {
            delegate.alarmNotificationDidFinish(self)
        }
    }
    
    func shouldStop(ifNotContainedIn dataModelIdentifiers: Set<String>) -> Bool {
        return !dataModelIdentifiers.contains(self.itemID)
    }
}


