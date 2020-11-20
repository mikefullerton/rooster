//
//  AlarmController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation

protocol AlarmControllerDelegate : AnyObject {
    func alarmControllerDidRequestCalendarAccess(_ alarmController: AppController, success:Bool, error: Error?)
}

class AppController : CalendarManagerDelegate, AlarmSoundManagerDelegate {

    static let CalendarDidAuthenticateEvent = NSNotification.Name("AlarmControllerDidAuthenticateEvent")

    static let instance = AppController()
    
    weak var delegate: AlarmControllerDelegate?
    
    let alarmSoundManager: AlarmSoundManager
    let calendarManager: CalendarManager
    let preferences: Preferences
    
    private weak var timer: Timer?
    private(set) var isAuthenticating : Bool = false
    private(set) var isAuthenticated: Bool = false

    init() {
        let prefs = Preferences()
        self.preferences = prefs
        self.calendarManager = CalendarManager(withPreferences: prefs)
        self.alarmSoundManager = AlarmSoundManager()
        self.calendarManager.delegate = self
        self.alarmSoundManager.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: Preferences.DidChangeEvent, object: nil)
    }
    
    @objc func preferencesDidChange(_ notif: Notification) {
        self.calendarManager.reloadData()
    }
    
    func startTimerForNextEventTime() {
        print("timer stopped")
        self.stopTimer()
        
        if let nextEventTime = self.nextEventTime {
            self.startTimer(withDate: nextEventTime)
        }
    }
    
    func startTimer(withDate date: Date) {
        
        let fireTime = date.timeIntervalSinceReferenceDate
        let now = Date().timeIntervalSinceReferenceDate
        
        let fireInterval = fireTime - now
        
        let timer = Timer.scheduledTimer(withTimeInterval: fireInterval, repeats: false) { (timer) in
            print("timer fired after: \(fireInterval)")
            self.updateAlarms()
        }
        
        print("started timer: \(timer) for time interval \(fireInterval)")
    }
    
    func stopTimer() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }

    func fireAlarm(forEvent event: EventKitEvent) {
        self.calendarManager.setEventIsFiring(event)

        let alarmSound = RoosterCrowingAlarmSound()
        alarmSound?.play(for: event)
    }

    func stopAlarm(forEvent event: EventKitEvent) {
        self.calendarManager.setEventHasFired(event)

        if let alarmSound = self.alarmSoundManager.sound(forObject: event) {
            alarmSound.stop()
        }
    }
    
    var nextEventTime: Date? {
        
        let now = Date()
        
        for event in self.calendarData.events {
            if event.startDate.isAfterDate(now) {
                return event.startDate
            }

            if event.startDate.isAfterDate(now) {
                return event.endDate
            }
        }
        
        let currentCalendar = NSCalendar.current
        
        let dateComponents = currentCalendar.dateComponents([.year, .month, .day], from: Date())
        
        if let today = currentCalendar.date(from: dateComponents),
           let tomorrow: Date = currentCalendar.date(byAdding: .day, value: 1, to: today) {
            
            return tomorrow
        }
        
        return nil
    }
    
    func stopAlarmsIfNeeded() {
        var events:[EventKitEvent] = []
        
        for event in self.calendarData.events {
            if event.isFiring && (!event.isInProgress || event.hasFired) {
                events.append(event)
            }
        }

        for event in events {
            self.stopAlarm(forEvent: event)
        }
    }
    
    func fireAlarmsIfNeeded() {
        
        var events: [EventKitEvent] = []
        
        for event in self.calendarData.events {
            if event.isInProgress &&
                event.hasFired == false &&
                event.isFiring == false {
                events.append(event)
            }
        }
   
        for event in events {
            self.fireAlarm(forEvent: event)
        }
    }
    
    func updateFiredAlarmsInPrefs() {
        var eventIdentifiers: [String] = []
        
        for event in self.calendarData.events {
            if event.hasFired {
                eventIdentifiers.append(event.id)
            }
        }
        
        self.preferences.firedEvents.replaceAll(withIdentifiers: eventIdentifiers, notifyListeners: false)
    }
    
    func updateAlarms() {
        self.stopAlarmsIfNeeded()
        self.fireAlarmsIfNeeded()
        self.updateFiredAlarmsInPrefs()
        self.startTimerForNextEventTime()
    }
        
    func start() {
        self.isAuthenticating = true
        self.calendarManager.requestAccess { (success, error) in
            DispatchQueue.main.async {
                self.isAuthenticating = false
                if success {
                    self.isAuthenticated = true
                    self.updateAlarms()
                }
                
                if self.delegate != nil {
                    self.delegate!.alarmControllerDidRequestCalendarAccess(self, success: success, error: error)
                }
                
                NotificationCenter.default.post(name: AppController.CalendarDidAuthenticateEvent, object: self)
            }
        }
    }
    
    func calendarManagerCalendarStoreDidUpdate(_ calendarManager: CalendarManager) {
//        self.updateAlarms()
    }

    func calendarManagerDidReload(_ calendarManager: CalendarManager) {
        self.updateAlarms()
    }
    
    func alarmSoundManager(_ manager: AlarmSoundManager, soundWillStartPlaying sound: AlarmSound) {
        
    }
    
    func alarmSoundManager(_ manager: AlarmSoundManager, soundDidStopPlaying sound: AlarmSound) {
        
    }

    var calendarData: CalendarData {
        return self.calendarManager.data
    }
//    
//    var events: [EventKitEvent] {
//        return self.calendarData.events
//    }
//
//    var calendars: [String: [EventKitCalendar]] {
//        return self.calendarData.calendars
//    }
//
//    var reminders: [EventKitReminder] {
//        return self.calendarData.reminders
//    }
//    
//    var delegate
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
