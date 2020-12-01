//
//  AlarmController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import UIKit

class AppController : AlarmSoundManagerDelegate {

    static let CalendarDidAuthenticateEvent = NSNotification.Name("AlarmControllerDidAuthenticateEvent")

    static let instance = AppController()
    
    let alarmSoundManager: AlarmSoundManager
    let calendarManager: CalendarManager
    
    private weak var timer: Timer?
    private(set) var isAuthenticating : Bool = false
    private(set) var isAuthenticated: Bool = false
    
    var firingEvents:Set<String> = Set()
    
    init() {
        self.calendarManager = CalendarManager(withDataModel: DataModel.instance, preferences: DataModel.instance.preferences)
        self.alarmSoundManager = AlarmSoundManager()
        self.alarmSoundManager.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(dataModelDidChange(_:)), name: DataModel.DidChangeEvent, object: nil)
    }
    
    @objc private func dataModelDidChange(_ notif: Notification) {
        self.handleDataModelChanged()
    }

    private func startTimerForNextEventTime() {
//        print("timer stopped")
        self.stopTimer()
        
        if let nextEventTime = DataModel.instance.nextEventTime {
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
        if event.isFiring {
            self.startAlarm(forIdentifier: event.id)
        } else {
            self.stopAlarm(forIdentifier: event.id)
        }
    }
    
    private func updateAlarmStatesForChangedEvents() {
        DataModel.instance.events.forEach {
            self.updateAlarmState(forEvent: $0)
        }
    }
    
    func stopAlarmsForFinishedEvents() {
        var events:[EventKitEvent] = []

        for event in DataModel.instance.events {
            if event.isFiring && (!event.isInProgress || event.hasFired) {
                events.append(event.updatedEvent(didStartFiring: true,
                                                 isFiring: false,
                                                 hasFired: true))
            }
        }

        if events.count > 0 {
            DispatchQueue.main.async {
                DataModel.instance.update(someEvents: events)
            }
        }
    }
    
    func stopAlarmsForMissingEvents() {
        let identifiers = DataModel.instance.events.map {
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
    
    func findURL(inEvent event: EventKitEvent, withString string: String) -> URL? {
        if let location = event.location,
           location.contains(string),
           let url = URL(string: location) {
            return url
        }
        
        if let url = event.URL,
           url.absoluteString.contains(string) {
            return url
        }
        
        if let noteURLs = event.noteURLS {
            for url in noteURLs {
                if url.absoluteString.contains(string) {
                    return url
                }
            }
        }
        
        return nil
    }
    
    
    func eventDidStartFiring(event: EventKitEvent) {
        if let webexURL = self.findURL(inEvent: event, withString: "webex") {
            UIApplication.shared.open(webexURL,
                                      options: [:]) { (success) in
                
            }
        }
    }

    func fireAlarmsIfNeeded() {
        var events: [EventKitEvent] = []

        for event in DataModel.instance.events {
            if event.isInProgress &&
                event.hasFired == false &&
                event.isFiring == false {
                
                if event.didStartFiring == false {
                    self.eventDidStartFiring(event: event)
                }
                
                events.append(event.updatedEvent(didStartFiring: true,
                                                 isFiring: true,
                                                 hasFired: false))
            }
        }

        if events.count > 0 {
            DispatchQueue.main.async {
                DataModel.instance.update(someEvents: events)
            }
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
        self.isAuthenticating = true
        self.calendarManager.requestAccess { (success, error) in
            DispatchQueue.main.async {
                self.isAuthenticating = false
                if success {
                    self.isAuthenticated = true
                }
                NotificationCenter.default.post(name: AppController.CalendarDidAuthenticateEvent, object: self)
            }
        }
    }
    
    func alarmSoundManager(_ manager: AlarmSoundManager, soundWillStartPlaying sound: AlarmSound) {
        
    }
    
    func alarmSoundManager(_ manager: AlarmSoundManager, soundDidStopPlaying sound: AlarmSound) {
        
    }

}

