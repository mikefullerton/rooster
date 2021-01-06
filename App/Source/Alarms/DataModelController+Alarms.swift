//
//  DataModel+Alarms.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation

extension DataModelController {
    

    func stopAllAlarms() {
        if let updatedEvents = self.stopAlarms(forItems: DataModelController.dataModel.events)  {
            self.update(someEvents: updatedEvents)
        }

        if let updatedReminders = self.stopAlarms(forItems: DataModelController.dataModel.reminders) {
            self.update(someReminders: updatedReminders)
        }
    }
    
    private func stopAlarms<T>(forItems items: [T]) -> [T]? where T: CalendarItem {
        var outList:[T] = []
        var madeChange = false
        
        for item in items {
            if item.alarm.state == .firing {
                var updatedAlarm = item.alarm
                updatedAlarm.state = .finished
                
                var updatedItem = item
                updatedItem.alarm = updatedAlarm
                outList.append(updatedItem)
                
                madeChange = true
            } else {
                outList.append(item)
            }
        }
        
        return madeChange ? outList : nil
    }
    
    private func updateAlarms<T>(forItems items: [T]) -> [T]? where T: CalendarItem {
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
                
                var updatedAlarm = alarm
                updatedAlarm.state = alarmState
                
                var updatedItem = item
                updatedItem.alarm = updatedAlarm
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
