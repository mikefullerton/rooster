//
//  AlarmController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation

protocol AlarmControllerDelegate : AnyObject {
    func alarmControllerDidRequestCalendarAccess(_ alarmController: AlarmController, success:Bool, error: Error?)
}

class AlarmController : CalendarManagerDelegate {
    static let instance = AlarmController()
    
    weak var delegate: AlarmControllerDelegate?
    
    var calendarAccessError: Error?
    var hasCalendarAccess: Bool
    
    private weak var timer: Timer?
    
    init() {
        self.calendarAccessError = nil
        self.hasCalendarAccess = false
        CalendarManager.instance.delegate = self
    }
    
    func startTimer() {
        print("timer stopped")
        self.stopTimer()
        
        if let nextEventTime = CalendarManager.instance.nextEventTime {
            self.startTimer(withDate: nextEventTime)
        }
    }
    
    func stopTimer() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }

    func fireAlarm(forEvent event: Event) {
        AlarmSoundManager.instance.playAlarmSound()
        CalendarManager.instance.setEventIsFiring(event)
    }

    func stopAlarm(forEvent event: Event) {
        AlarmSoundManager.instance.silenceAlarmSound()
        CalendarManager.instance.setEventHasFired(event)
    }
    
    func fireAlarmsIfNeeded() {
        if let events = CalendarManager.instance.eventsNeedingAlarms() {
            for event in events {
                self.fireAlarm(forEvent: event)
            }
        }
        self.startTimer()
    }
        
    func startTimer(withDate date: Date) {
        
        let fireTime = date.timeIntervalSinceReferenceDate
        let now = Date().timeIntervalSinceReferenceDate
        
        let fireInterval = fireTime - now
        
        let timer = Timer.scheduledTimer(withTimeInterval: fireInterval, repeats: false) { (timer) in
            print("timer fired after: \(fireInterval)")
            self.fireAlarmsIfNeeded()
        }
        
        print("started timer: \(timer) for time interval \(fireInterval)")
    }
    
    
    func start() {
        CalendarManager.instance.requestAccess { (success, error) in
            DispatchQueue.main.async {
                self.hasCalendarAccess = success
                self.calendarAccessError = error
                if success {
                    self.fireAlarmsIfNeeded()
                }
                
                if self.delegate != nil {
                    self.delegate!.alarmControllerDidRequestCalendarAccess(self, success: success, error: error)
                }
            }
        }
    }
    
    func calendarManagerDidUpdate(_ calendarManager: CalendarManager) {
        self.fireAlarmsIfNeeded()
    }
    
}

extension Event {
    func stopAlarm() {
        AlarmController.instance.stopAlarm(forEvent: self)
    }
}
