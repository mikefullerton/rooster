//
//  AlarmController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import UIKit
import OSLog

/// Highlest level controller. This controls the alarms.
class AlarmController {
    
    private static let logger = Logger(subsystem: "com.apple.rooster", category: "AlarmController")

    public static let CalendarDidAuthenticateEvent = NSNotification.Name("AlarmControllerDidAuthenticateEvent")
    public static let AlarmsWillStartEvent = NSNotification.Name("AlarmsWillStartEvent")
    public static let AlarmsDidStopEvent = NSNotification.Name("AlarmsDidStopEvent")

    public static let instance = AlarmController()
    
    // private
    private let timer: SimpleTimer
    private let alarmSoundController: AlarmSoundController
    
    private init() {
        self.timer = SimpleTimer()
        self.alarmSoundController = AlarmSoundController()
        
        NotificationCenter.default.addObserver(self, selector: #selector(dataModelDidChange(_:)), name: EventKitDataModelController.DidChangeEvent, object: nil)
    }
    
    var alarmsAreFiring: Bool {
        return self.alarmSoundController.playingCount > 0
    }
    
    var logger: Logger {
        return AlarmController.logger
    }
    
    public func stopAllAlarms() {
        self.stopAlarmsForMissingOrFutureItems()

        if let updatedEvents = self.stopAlarms(forItems: EventKitDataModelController.dataModel.events)  {
            EventKitDataModelController.instance.update(someEvents: updatedEvents)
        }
    
        if let updatedReminders = self.stopAlarms(forItems: EventKitDataModelController.dataModel.reminders) {
            EventKitDataModelController.instance.update(someReminders: updatedReminders)
        }
        
        self.logger.log("Stopped all alarms")
        
        self.startTimerForNextEventTime()
    }

    // MARK: timer management
    
    private func startTimerForNextEventTime() {
        self.timer.stop()
        
        if let nextEventTime = EventKitDataModelController.dataModel.nextEventTime {
            self.startTimer(withDate: nextEventTime)
        }
    }
    
    private func startTimer(withDate date: Date) {
        self.timer.start(withDate: date) { (timer) in
            self.logger.log("timer did fire after: \(timer.timeInterval)")
            self.handleDataModelChanged()
        }
    }
    
    // MARK: alarm management
    
    private func notifyIfAlarmsStopped() {
        DispatchQueue.main.async {
            if self.alarmSoundController.playingCount == 0 {
                self.logger.log("Notifying that all alarms have stopped")
                NotificationCenter.default.post(name: AlarmController.AlarmsDidStopEvent, object: self)
            }
        }
    }
    
    private func stopPlayingAlarmIfPlaying(forItem item: Alarmable) {
        self.alarmSoundController.stopPlayingSound(forItem: item)
        self.notifyIfAlarmsStopped()
    }
    
    private func playAlarmSoundIfNeeded(forItem item: Alarmable) {
        
        let notify = self.alarmSoundController.playingCount == 0
        
        self.alarmSoundController.startPlayingSound(forItem: item)

        if notify {
            self.logger.log("Notifying that alarms will start")
            NotificationCenter.default.post(name: AlarmController.AlarmsWillStartEvent, object: self)
        }
    }
    
    private func stopAlarmsForMissingOrFutureItems() {
        let items:[Alarmable] = EventKitDataModelController.dataModel.events + EventKitDataModelController.dataModel.reminders
        
        var itemsSet = Set<String>()
        
        items.forEach { (item) in
            if !item.alarm.isHappeningNow {
                self.stopPlayingAlarmIfPlaying(forItem: item)
            } else {
                itemsSet.insert(item.id)
            }
        }
        
        self.alarmSoundController.visitPlayingSounds() { (item, sound) in
            if !itemsSet.contains(item.id) {
                self.alarmSoundController.stopPlayingSound(forItem: item)
            }
        }
    }
    
    private func startAlarm<T>(forItem item: T) where T: EventKitItem {
        self.openEventLocationURL(forItem: item)
        self.playAlarmSoundIfNeeded(forItem:item)

// Do we want this since you can just click in the menubar now?
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
//            AppKitPlugin.instance.bringAppToFront()
//        }
    }
    
    private func updateAlarms<T>(forItems items: [T]) -> [T]? where T: EventKitItem {
        var outList:[T] = []
        var madeChange = false
        
        for item in items {
            
            self.alarmSoundController.updateItemIfPlaying(item)
            
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
    
    // MARK: data model interaction
    
    @objc private func dataModelDidChange(_ notif: Notification) {
        self.handleDataModelChanged()
    }
    
    private func handleDataModelChanged() {

        self.stopAlarmsForMissingOrFutureItems()

        if let updatedEvents = self.updateAlarms(forItems: EventKitDataModelController.dataModel.events)  {
            EventKitDataModelController.instance.update(someEvents: updatedEvents)
        }
    
        if let updatedReminders = self.updateAlarms(forItems: EventKitDataModelController.dataModel.reminders) {
            EventKitDataModelController.instance.update(someReminders: updatedReminders)
        }
    
        self.startTimerForNextEventTime()
    }
    
    /// called by the AppDelegate
    public func start() {
        EventKitDataModelController.instance.authenticate { (success) in
            NotificationCenter.default.post(name: AlarmController.CalendarDidAuthenticateEvent, object: self)
        }
    }
}

extension AlarmController {
    func openEventLocationURL<T>(forItem item: T) where T: EventKitItem {
        if let locationURL = item.bestLocationURL {
            
            self.logger.log("Opening location URL: \(locationURL) forItem: \(item.title)")
            
            UIApplication.shared.open(locationURL,
                                      options: [:]) { (innerSuccess) in
                
            }
            
            if let bundleID = item.bestAppBundle {
                AppKitPluginController.instance.utilities.bringAnotherApp(toFront: bundleID)
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

