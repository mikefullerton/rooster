//
//  AlarmController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation

class AppController : AlarmSoundManagerDelegate {

    static let CalendarDidAuthenticateEvent = NSNotification.Name("AlarmControllerDidAuthenticateEvent")

    static let instance = AppController()
    
    let alarmSoundManager: AlarmSoundManager
    let calendarManager: CalendarManager
    
    private weak var timer: Timer?
    private(set) var isAuthenticating : Bool = false
    private(set) var isAuthenticated: Bool = false

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

    private func updateAlarmState(forEvent event: EventKitEvent) {
        if event.isFiring {
            guard self.alarmSoundManager.sound(forObject: event) == nil else {
                // already firing
                return
            }
            
            let alarmSound = RoosterCrowingAlarmSound()
            alarmSound?.play(for: event)
        } else if let alarmSound = self.alarmSoundManager.sound(forObject: event) {
            alarmSound.stop()
        }
    }
    
    func updateAlarmStates() {
        for event in DataModel.instance.events {
            self.updateAlarmState(forEvent: event)
        }
    }
    
    private func handleDataModelChanged() {
        DataModel.instance.stopAlarmsIfNeeded()
        DataModel.instance.fireAlarmsIfNeeded()
        self.updateAlarmStates()
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

class Notifier {
    let name: Notification.Name

    init(withName name: Notification.Name, object: AnyObject? = nil) {
        self.name = name
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationReceived(_:)),
                                               name: AppController.CalendarDidAuthenticateEvent, object: object)
    }
    
    @objc func notificationReceived(_ notif: Notification) {
        
    }
    
}

protocol Reloadable {
    func reload()
}

class Reloader : Notifier {
    
    let reloadable: Reloadable
    
    init(withName name: Notification.Name, reloadable: Reloadable) {
        self.reloadable = reloadable
        super.init(withName: name)
    }

    @objc override func notificationReceived(_ notif: Notification) {
        print("got reload event")
        self.reloadable.reload()
    }
}

class AuthenticationReloader : Reloader {
    init(for reloadable:Reloadable) {
        super.init(withName: AppController.CalendarDidAuthenticateEvent, reloadable: reloadable)
    }
}
