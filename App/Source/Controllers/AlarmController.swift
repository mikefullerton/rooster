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
    private weak var timer: Timer?
    private var firingEvents:[String: Alarmable]
    private let alarmSoundManager: AlarmSoundManager
    
    private init() {
        self.timer = nil
        self.alarmSoundManager = AlarmSoundManager()
        self.firingEvents = [:]

        NotificationCenter.default.addObserver(self, selector: #selector(dataModelDidChange(_:)), name: EventKitDataModelController.DidChangeEvent, object: nil)
    }
    
    var alarmsAreFiring: Bool {
        return self.firingEvents.count > 0
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
            self.logger.log("timer did fire after: \(fireInterval)")
            self.handleDataModelChanged()
        }
        self.timer = timer
        
//        logger.log("started timer: \(timer) for time interval \(fireInterval)")
    }
    
    private func stopTimer() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    // MARK: alarm management
    
    private func notifyIfAlarmsStopped() {
        DispatchQueue.main.async {
            if self.firingEvents.count == 0 {
                self.logger.log("Notifying that all alarms have stopped")
                NotificationCenter.default.post(name: AlarmController.AlarmsDidStopEvent, object: self)
            }
        }
    }
    
    private func stopPlayingAlarmIfPlaying<T>(forItem item: T) where T: EventKitItem {
        if let alarmSound = self.alarmSoundManager.sound(forIdentifier: item.id) {
            self.firingEvents.removeValue(forKey: item.id)
            alarmSound.stop()
            self.logger.log("Stopped alarm sound: \(alarmSound.name) for \(item.title)")
            
            self.notifyIfAlarmsStopped()
        }
    }
    
    private func playAlarmSoundIfNeeded<T>(forItem item: T) where T: EventKitItem {
        
        if self.firingEvents[item.id] == nil {
            
            let notify = self.firingEvents.count == 0
            
            self.firingEvents[item.id] = item
            
            guard self.alarmSoundManager.sound(forIdentifier: item.id) == nil else {
                // already firing
                return
            }
            
            let alarmSound = RoosterCrowingAlarmSound()
            alarmSound?.play(forIdentifier: item.id)

            self.logger.log("Started alarm sound: \(alarmSound?.name ?? "nil" ) for \(item.title)")
        
            if notify {
                self.logger.log("Notifying that alarms will start")
                NotificationCenter.default.post(name: AlarmController.AlarmsWillStartEvent, object: self)
            }
        }
    }
    
    private func stopAlarmsForMissingOrFutureItems<T>(_ items: [T]) where T: EventKitItem {
        
        var itemsSet = Set<String>()
        
        items.forEach { (item) in
            itemsSet.insert(item.id)
            
            if !item.alarm.isHappeningNow {
                self.stopPlayingAlarmIfPlaying(forItem: item)
            }
        }
        
        self.firingEvents.forEach { (key, item) in
            if itemsSet.contains(key),
               let typedItem = item as? T {
                self.stopPlayingAlarmIfPlaying(forItem: typedItem)
            }
        }
    }
    
    private func stopAlarmsForMissingOrFutureItems() {
        self.stopAlarmsForMissingOrFutureItems(EventKitDataModelController.dataModel.events)
        self.stopAlarmsForMissingOrFutureItems(EventKitDataModelController.dataModel.reminders)
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
            
            if self.firingEvents[item.id] != nil {
                self.firingEvents[item.id] = item
            }
            
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
    
    func alarmSoundManager(_ manager: AlarmSoundManager, soundWillStartPlaying sound: AlarmSound) {
        
    }
    
    func alarmSoundManager(_ manager: AlarmSoundManager, soundDidStopPlaying sound: AlarmSound) {
        
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

