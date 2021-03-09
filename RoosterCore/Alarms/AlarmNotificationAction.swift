//
//  AlarmNotificationAction.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/18/21.
//

import Foundation

open class AlarmNotificationAction: Loggable, CustomStringConvertible {
    
    public private(set) var itemID: String = ""
    public private(set) weak var alarmNotification: AlarmNotification?
    
    public var alarmState: AlarmNotificationController.AlarmState = .zero {
        didSet {
            self.alarmNotification?.alarmState = self.alarmState
        }
    }
    
    public private(set) var isDone: Bool = false {
        didSet {
            if oldValue != self.isDone && self.isDone {
                self.alarmNotification?.actionDidFinish(self)
            }
        }
    }
    
    public init() {
        
    }
    
    public func setFinished() {
        self.isDone = true
    }
    
    func willStartAction(withItemID itemID: String,
                                 alarmNotification: AlarmNotification) {
        self.itemID = itemID
        self.alarmNotification = alarmNotification
    }
    
    deinit {
        self.stopAction()
        self.isDone = true
    }
    
    open func startAction() {
        
    }
    
    open func stopAction() {
        
    }
    
    public var calendarItem: RCCalendarItem? {
        let dataModel = Controllers.dataModel.dataModel
        return dataModel?.item(forIdentifier: self.itemID)
    }
    
    public var description: String {
        return """
        type(of(self)): \
        itemID: \(self.itemID), \
        alarm: \(self.alarmNotification?.description ?? "nil")
        """
    }
}

