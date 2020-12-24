//
//  EventKitDataModel+Alarms.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation

extension EventKitDataModelController {
    

    func stopAllAlarms() {
        if let updatedEvents = self.stopAlarms(forItems: EventKitDataModelController.dataModel.events)  {
            self.update(someEvents: updatedEvents)
        }

        if let updatedReminders = self.stopAlarms(forItems: EventKitDataModelController.dataModel.reminders) {
            self.update(someReminders: updatedReminders)
        }
    }
    
    private func stopAlarms<T>(forItems items: [T]) -> [T]? where T: EventKitItem {
        var outList:[T] = []
        var madeChange = false
        
        for item in items {
            if item.alarm.state == .firing {
                let updatedAlarm = item.alarm.alarmWithUpdatedState(.finished)
                
                let updatedItem = item.itemWithUpdatedAlarm(updatedAlarm) as! T // wth, why do I need to cast this?
                
                outList.append(updatedItem)
                
                madeChange = true
            } else {
                outList.append(item)
            }
        }
        
        return madeChange ? outList : nil
    }
    
    private func updateAlarms<T>(forItems items: [T]) -> [T]? where T: EventKitItem {
        var outList:[T] = []
        var madeChange = false
        
        for item in items {
            let alarm = item.alarm
            var alarmState = alarm.state
            
            if !alarm.isEnabled {
                alarmState = .disabled
            
            } else if alarm.isHappeningNow {
                
                if alarmState == .neverFired {
                    alarmState = .firing
                }
                    
            } else {
                alarmState = .neverFired
            }
            
            if alarmState != alarm.state {
                let updatedAlarm = alarm.alarmWithUpdatedState(alarmState)
                
                let updatedItem = item.itemWithUpdatedAlarm(updatedAlarm) as! T // wth, why do I need to cast this?
                
                outList.append(updatedItem)
                
                madeChange = true
            } else {
                outList.append(item)
            }
                
        }
        
        return madeChange ? outList : nil
    }
    
    public func updateAlarmsIfNeeded() {
        if let updatedEvents = self.updateAlarms(forItems: self.dataModel.events)  {
            self.update(someEvents: updatedEvents)
        }
    
        if let updatedReminders = self.updateAlarms(forItems: self.dataModel.reminders) {
            self.update(someReminders: updatedReminders)
        }
    }
}
