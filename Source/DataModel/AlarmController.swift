//
//  AlarmController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import UIKit

class AlarmController : AlarmSoundManagerDelegate {

    static let CalendarDidAuthenticateEvent = NSNotification.Name("AlarmControllerDidAuthenticateEvent")

    static let instance = AlarmController()
    
    private let alarmSoundManager: AlarmSoundManager
    private weak var timer: Timer?
    private var firingEvents:Set<String>
    
    init() {
        self.timer = nil
        self.firingEvents = Set<String>()
        self.alarmSoundManager = AlarmSoundManager()
        
        
        // finish init
        self.alarmSoundManager.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(dataModelDidChange(_:)), name: EventKitDataModelController.DidChangeEvent, object: nil)
    }
    
    @objc private func dataModelDidChange(_ notif: Notification) {
        self.handleDataModelChanged()
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

    private func stopAlarm(forIdentifier identifer: String) {
        if let alarmSound = self.alarmSoundManager.sound(forIdentifier: identifer) {
            self.firingEvents.remove(identifer)
            alarmSound.stop()
        }
    }
    
    private func startAlarm(forIdentifier identifer: String) {
        self.firingEvents.insert(identifer)
        
        guard self.alarmSoundManager.sound(forIdentifier: identifer) == nil else {
            // already firing
            return
        }
        
        let alarmSound = RoosterCrowingAlarmSound()
        alarmSound?.play(forIdentifier: identifer)
    }
    
    private func updateAlarmState(forEvent event: EventKitEvent) {
        if event.alarmState == .firing {
            self.startAlarm(forIdentifier: event.id)
        } else {
            self.stopAlarm(forIdentifier: event.id)
        }
    }
    
    private func updateAlarmStatesForChangedEvents() {
        EventKitDataModelController.dataModel.events.forEach {
            self.updateAlarmState(forEvent: $0)
        }
    }
    
    func stopAlarmsForFinishedEvents() {
        var events:[EventKitEvent] = []

        for event in EventKitDataModelController.dataModel.events {
            if event.alarmState == .firing && !event.isHappeningNow {
                events.append(event.eventWithUpdatedAlarmState(.finished))
            }
        }

        if events.count > 0 {
            EventKitDataModelController.instance.update(someEvents: events)
        }
    }
    
    func stopAlarmsForMissingEvents() {
        let identifiers = EventKitDataModelController.dataModel.events.map {
            $0.id
        }
        
        var alarmsToStop: [String] = []
        self.firingEvents.forEach {
            if !identifiers.contains($0) {
                alarmsToStop.append($0)
            }
        }
        
        alarmsToStop.forEach {
            self.stopAlarm(forIdentifier: $0)
        }
    }
    
    func eventDidStartFiring(event: EventKitEvent) {
        self.openEventLocationURL(event)
        
        self.startAlarm(forIdentifier: event.id)
    }

    func fireAlarmsIfNeeded() {
        var events: [EventKitEvent] = []

        for event in EventKitDataModelController.dataModel.events {
            if event.isHappeningNow &&
                event.alarmState != .finished {
                
                if event.alarmState == .neverFired {
                    self.eventDidStartFiring(event: event)
                }

                events.append(event.eventWithUpdatedAlarmState(.firing))
            }
        }

        if events.count > 0 {
            EventKitDataModelController.instance.update(someEvents: events)
        }
    }
    
    private func handleDataModelChanged() {
        self.stopAlarmsForFinishedEvents()
        self.stopAlarmsForMissingEvents()
        self.fireAlarmsIfNeeded()
        self.updateAlarmStatesForChangedEvents()
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
    
    func openEventLocationURL(_ event: EventKitEvent?) {
        if let webexURL = event?.bestLocationURL {
            UIApplication.shared.open(webexURL,
                                      options: [:]) { (success) in
                
            }
        }
    }

}

extension EventKitEvent {
    var bestLocationURL: URL? {
        return self.findURL(containing: "webex")
    }
}
