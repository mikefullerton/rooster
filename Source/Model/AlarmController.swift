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

class AlarmController : CalendarManagerDelegate, AlarmSoundManagerDelegate {
    static let instance = AlarmController()
    
    weak var delegate: AlarmControllerDelegate?
    
    let alarmSoundManager: AlarmSoundManager
    let calendarManager: CalendarManager
    let preferences: Preferences
    
    private weak var timer: Timer?
    
    init() {
        let prefs = Preferences()
        
        self.preferences = prefs
        
        self.calendarManager = CalendarManager(withPreferences: prefs)
        
        self.alarmSoundManager = AlarmSoundManager()
        
        self.calendarManager.delegate = self
        self.alarmSoundManager.delegate = self
    }
    
    func startTimer() {
        print("timer stopped")
        self.stopTimer()
        
        if let nextEventTime = self.calendarManager.nextEventTime {
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
        event.alarmSound = RoosterCrowingAlarmSound()
        event.alarmSound?.play()
        self.calendarManager.setEventIsFiring(event)
    }

    func stopAlarm(forEvent event: Event) {
        event.alarmSound?.stop()
        event.alarmSound = nil
        self.calendarManager.setEventHasFired(event)
    }
    
    func fireAlarmsIfNeeded() {
        if let events = self.calendarManager.eventsNeedingAlarms() {
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
        self.calendarManager.requestAccess { (success, error) in
            DispatchQueue.main.async {
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
    
    func alarmSoundManager(_ manager: AlarmSoundManager, soundWillStartPlaying sound: AlarmSound) {
        
    }
    
    func alarmSoundManager(_ manager: AlarmSoundManager, soundDidStopPlaying sound: AlarmSound) {
        
    }

    
}

extension Event {
    func stopAlarm() {
        AlarmController.instance.stopAlarm(forEvent: self)
    }
}
