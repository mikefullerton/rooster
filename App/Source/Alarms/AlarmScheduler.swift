//
//  AlarmController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import UIKit

/// This is the controller that takes care of scheduling the alarms, etc.
class AlarmScheduler: Loggable, DataModelAware {
    
    public static let instance = AlarmScheduler()
    
    private var reloader: DataModelReloader?
    
    // private
    private let timer: SimpleTimer
    
    private init() {
        self.timer = SimpleTimer()
        self.reloader = DataModelReloader(for: self)
    }
    
    // MARK: timer management
    
    private func startTimerForNextEventTime() {
        self.timer.stop()
        
        if let nextEventTime = EventKitDataModelController.dataModel.nextActionableAlarmDate {
            self.startTimer(withDate: nextEventTime)
        }
    }
    
    private func startTimer(withDate date: Date) {
        self.timer.start(withDate: date) { (timer) in
            self.logger.log("timer did fire after: \(timer.timeInterval)")
            self.handleDataModelChanged()
        }
    }
    
    // MARK: data model interaction

    func dataModelDidReload(_ dataModel: EventKitDataModel) {
        self.handleDataModelChanged()
    }
    
    private func handleDataModelChanged() {
        EventKitDataModelController.instance.updateAlarmsIfNeeded()
        self.startTimerForNextEventTime()
    }
    
    /// called by the AppDelegate
    public func start() {
        self.handleDataModelChanged()
    }
}

