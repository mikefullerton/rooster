//
//  AlarmController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import UIKit

class AlarmController {

    static let CalendarDidAuthenticateEvent = NSNotification.Name("AlarmControllerDidAuthenticateEvent")

    static let AlarmsDidStartEvent = NSNotification.Name("AlarmsDidStartEvent")
    static let AlarmsDidStopEvent = NSNotification.Name("AlarmsDidStopEvent")

    static let instance = AlarmController()
    
    private weak var timer: Timer?
    
    private var firingEvents:Set<String>
    private let alarmSoundManager: AlarmSoundManager
    
    init() {
        self.timer = nil
        self.alarmSoundManager = AlarmSoundManager()
        self.firingEvents = Set<String>()

        NotificationCenter.default.addObserver(self, selector: #selector(dataModelDidChange(_:)), name: EventKitDataModelController.DidChangeEvent, object: nil)
    }
    
    var alarmsAreFiring: Bool {
        return self.firingEvents.count > 0
    }
    
    private func startTimerForNextEventTime() {
//        print("timer stopped")
        self.stopTimer()
        
        if let nextEventTime = EventKitDataModelController.dataModel.nextEventTime {
            self.startTimer(withDate: nextEventTime)
        }
    }
    
    private func startTimer(withDate date: Date) {
        self.stopTimer()
        
        let fireTime = date.timeIntervalSinceReferenceDate
        let now = Date().timeIntervalSinceReferenceDate
        
        let fireInterval = fireTime - now
        
        let timer = Timer.scheduledTimer(withTimeInterval: fireInterval, repeats: false) { (timer) in
//            print("timer fired after: \(fireInterval)")
            self.timerDidFire()
        }
        self.timer = timer
        
//        print("started timer: \(timer) for time interval \(fireInterval)")
    }
    
    private func stopTimer() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }

    private func stopAlarmIfPlaying(forIdentifier identifer: String) {
        if let alarmSound = self.alarmSoundManager.sound(forIdentifier: identifer) {
            self.firingEvents.remove(identifer)
            alarmSound.stop()

            if self.firingEvents.count == 0 {
                NotificationCenter.default.post(name: AlarmController.AlarmsDidStopEvent, object: self)
            }
        }
        
    }
    
    private func stopPlayingAlarmIfPlaying<T>(forItem item: T) where T: EventKitItem {
        self.stopAlarmIfPlaying(forIdentifier: item.id)
    }
    
    private func playAlarmSoundIfNeeded<T>(forItem item: T) where T: EventKitItem {
        
        if !self.firingEvents.contains(item.id) {
            
            if self.firingEvents.count == 0 {
                NotificationCenter.default.post(name: AlarmController.AlarmsDidStartEvent, object: self)
            }
            
            self.firingEvents.insert(item.id)
            
            guard self.alarmSoundManager.sound(forIdentifier: item.id) == nil else {
                // already firing
                return
            }
            
            let alarmSound = RoosterCrowingAlarmSound()
            alarmSound?.play(forIdentifier: item.id)
        }
    }
    
    @objc private func dataModelDidChange(_ notif: Notification) {
        AlarmController.instance.handleDataModelChanged()
    }
    
    private func stopAlarmsForMissingOrFutureItems<T>(_ items: [T]) where T: EventKitItem {
        
        var itemsSet = Set<String>()
        
        items.forEach { (item) in
            itemsSet.insert(item.id)
            
            if !item.alarm.isHappeningNow {
                self.stopAlarmIfPlaying(forIdentifier: item.id)
            }
        }
        
        self.firingEvents.forEach {
            if itemsSet.contains($0) {
                self.stopAlarmIfPlaying(forIdentifier: $0)
            }
        }
    }
    
    private func stopAlarmsForMissingItems() {
        self.stopAlarmsForMissingOrFutureItems(EventKitDataModelController.dataModel.events)
        self.stopAlarmsForMissingOrFutureItems(EventKitDataModelController.dataModel.reminders)
    }
    
    private func startAlarm<T>(forItem item: T) where T: EventKitItem {
        self.openEventLocationURL(forItem: item)
        self.playAlarmSoundIfNeeded(forItem:item)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
            AppKitPlugin.instance.bringAppToFront()
        }
    }
    
    private func updateAlarms<T>(forItems items: [T]) -> [T]? where T: EventKitItem {
        var outList:[T] = []
        var madeChange = false
        
        for item in items {
            
            let alarm = item.alarm
            var alarmState = alarm.state
            
            if !alarm.isEnabled {
                alarmState = .willNeverFire
            } else if alarm.willFireInTheFuture {
                alarmState = .neverFired
            }
            
            switch(item.alarm.state) {
            case .neverFired:
                if alarm.isHappeningNow {
                    self.startAlarm(forItem: item)
                    alarmState = .firing
                }

            case .firing:
                if !alarm.isHappeningNow {
                    alarmState = .finished
                    self.stopPlayingAlarmIfPlaying(forItem: item)
                } else {
                    self.playAlarmSoundIfNeeded(forItem:item)
                }
        
            case .finished:
                self.stopPlayingAlarmIfPlaying(forItem: item)
            
            case .willNeverFire:
                self.stopPlayingAlarmIfPlaying(forItem: item)
            }
            
            if alarmState != alarm.state {
                let updatedAlarm = alarm.updatedAlarm(alarmState)
                
                let updatedItem = item.updateAlarm(updatedAlarm) as! T // wth, why do I need to cast this?
                
                outList.append(updatedItem)
                
                madeChange = true
            } else {
                outList.append(item)
            }
        }
        
        return madeChange ? outList : nil
    }
    
    private func stopAlarms<T>(forItems items: [T]) -> [T]? where T: EventKitItem {
        var outList:[T] = []
        var madeChange = false
        
        for item in items {
            
            let alarm = item.alarm
            var alarmState = alarm.state
            
            switch(item.alarm.state) {
            case .neverFired:
                break
            
            case .firing:
                alarmState = .finished
                self.stopPlayingAlarmIfPlaying(forItem: item)
                
            case .finished:
                self.stopPlayingAlarmIfPlaying(forItem: item)
            
            case .willNeverFire:
                break
            }
            
            if alarmState != alarm.state {
                let updatedAlarm = alarm.updatedAlarm(alarmState)
                
                let updatedItem = item.updateAlarm(updatedAlarm) as! T // wth, why do I need to cast this?
                
                outList.append(updatedItem)
                
                madeChange = true
            } else {
                outList.append(item)
            }
        }
        
        return madeChange ? outList : nil
    }
    
    public func stopAllAlarms() {
        self.stopAlarmsForMissingItems()

        if let updatedEvents = self.stopAlarms(forItems: EventKitDataModelController.dataModel.events)  {
            EventKitDataModelController.instance.update(someEvents: updatedEvents)
        }
    
        if let updatedReminders = self.stopAlarms(forItems: EventKitDataModelController.dataModel.reminders) {
            EventKitDataModelController.instance.update(someReminders: updatedReminders)
        }
    
        self.startTimerForNextEventTime()
    }
    
    private func handleDataModelChanged() {

        self.stopAlarmsForMissingItems()

        if let updatedEvents = self.updateAlarms(forItems: EventKitDataModelController.dataModel.events)  {
            EventKitDataModelController.instance.update(someEvents: updatedEvents)
        }
    
        if let updatedReminders = self.updateAlarms(forItems: EventKitDataModelController.dataModel.reminders) {
            EventKitDataModelController.instance.update(someReminders: updatedReminders)
        }
    
        self.startTimerForNextEventTime()
    }
    
    private func timerDidFire() {
        self.handleDataModelChanged()
    }
    
    func start() {
        EventKitDataModelController.instance.authenticate { (success) in
            NotificationCenter.default.post(name: AlarmController.CalendarDidAuthenticateEvent, object: self)
        }
    }
    
    func alarmSoundManager(_ manager: AlarmSoundManager, soundWillStartPlaying sound: AlarmSound) {
        
    }
    
    func alarmSoundManager(_ manager: AlarmSoundManager, soundDidStopPlaying sound: AlarmSound) {
        
    }
}

extension AlarmController {
    func openEventLocationURL<T>(forItem item: T) where T: EventKitItem {
        if let locationURL = item.bestLocationURL {
            UIApplication.shared.open(locationURL,
                                      options: [:]) { (innerSuccess) in
                
            }
            
            if let bundleID = item.bestAppBundle {
                AppKitPlugin.instance.bringAnotherApp(toFront: bundleID)
            }
        }
    }
}

extension EventKitItem {
    var bestLocationURL: URL? {
        return self.findURL(containing: "webex")
    }
    
    var bestAppBundle: String? {
        if self.bestLocationURL != nil {
            return "com.webex.meetingmanager"
        }
        
        return nil
    }
}

