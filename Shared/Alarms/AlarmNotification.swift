//
//  AlarmNotification.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation

protocol AlarmNotificationDelegate : AnyObject {
    func alarmNotificationDidStart(_ alarmNotification: AlarmNotification)
    func alarmNotificationDidFinish(_ alarmNotification: AlarmNotification)
}

class AlarmNotification: Equatable, Hashable, Loggable, CustomStringConvertible, SoundDelegate, Identifiable {
    
    enum State: String {
        case none = "None"
        case starting = "Starting"
        case started = "Started"
        case finished = "Finished"
        case aborted = "Aborted"
    }
    
    weak var delegate : AlarmNotificationDelegate?
    
    private var state: State
    private let timer: SimpleTimer
    private var sound: Sound?
    
    let id: String
    let itemID: String
    
    private static var idCounter:Int = 0
    
    init(withItemIdentifier itemIdentifier: String) {
        AlarmNotification.idCounter += 1

        self.id = "\(AlarmNotification.idCounter)"
        self.state = .none
        self.timer = SimpleTimer(withName: "AlarmNotificationTimer")
        self.sound = nil
        self.itemID = itemIdentifier
    }
   
    var item: CalendarItem? {
        let dataModel = AppDelegate.instance.dataModelController.dataModel
        return dataModel.item(forIdentifier: self.itemID)
    }
    
    private func performStartActions() {

        if let item = self.item {
            self.logger.log("performing start actions for \(self.description)")
            let prefs = AppDelegate.instance.preferencesController.notificationPreferences
            
            if prefs.options.contains(.autoOpenLocations) {
                self.logger.log("auto opening location URL (if available) for \(self.description)")
                
                item.openLocationURL()
                item.bringLocationAppsToFront()
            }
            
            if prefs.options.contains(.useSystemNotifications) {
                self.logger.log("posting system notifications for \(self.description)")

                AppDelegate.instance.userNotificationController.scheduleNotification(forItem: item)
            }
            
            #if os(macOS)
            
            if prefs.options.contains(.bounceAppIcon) {
                self.logger.log("bouncing app in dock for \(self.description)")

                AppDelegate.instance.systemUtilities.startBouncingAppIcon()
            }
            
            #endif
            
            #if targetEnvironment(macCatalyst)
            if prefs.bounceIconInDock {
                self.logger.log("bouncing app in dock for \(self.description)")

                AppDelegate.instance.appKitPlugin.utilities.startBouncingAppIcon()
            }
            #endif
        }
    }
    
    private func startPlayingSound() {
        let soundPrefs = AppDelegate.instance.preferencesController.preferences(forItemIdentifier: self.itemID).soundPreference
        
        guard soundPrefs.hasEnabledSoundPreferences else {
            self.logger.log("sounds disabled not playing sound")
            return
        }
        
        let iterator = soundPrefs.allSoundsIterator
       
        guard iterator.sounds.count > 0 else {
            self.logger.log("No sounds in iterators to play")
            return
        }
        
       //        return
        let sound = SoundPlayList(withPlayListIterator: iterator, displayName: "")
        sound.delegate = self
        self.sound = sound
        
        let soundBehavior = SoundBehavior(playCount: soundPrefs.playCount,
                                               timeBetweenPlays: 0.1,
                                               fadeInTime: 0)
        
        let interval = TimeInterval(soundPrefs.startDelay)
        
        self.logger.log("starting alarm sound for \(self.description), with interval: \(interval)")

        self.timer.start(withInterval:interval) { (timer) in
            
            self.logger.log("playing alarm sound: \(sound.displayName) for \(self.description)")

            sound.play(withBehavior: soundBehavior)
        }
    }

    func start() {
        self.state = .starting
        self.logger.log("starting alarm for \(self.description)")

        self.performStartActions()

        self.startPlayingSound()
        
        self.state = .started

        if let delegate = self.delegate {
            delegate.alarmNotificationDidStart(self)
        }
    }
    
    func stop() {
        self.logger.log("stopping alarm for \(self.description)")
        self.state = .aborted
        
        self.timer.stop()
        
        if let sound = self.sound {
            sound.stop()
        }

        if let item = self.item {
            AppDelegate.instance.userNotificationController.cancelNotifications(forItem: item)
        }
        
        if let delegate = self.delegate {
            delegate.alarmNotificationDidFinish(self)
        }
    }
    
    static func == (lhs: AlarmNotification, rhs: AlarmNotification) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    var description: String {
        return "\(type(of:self)): \(self.id), itemID: \(self.itemID), state: \(self.state.rawValue)"
    }
    
    func soundWillStartPlaying(_ sound: Sound) {
    }
    
    func soundDidStartPlaying(_ sound: Sound) {
    }

    func soundDidUpdate(_ sound: Sound) {
    }

    func soundDidStopPlaying(_ sound: Sound) {
        self.logger.log("alarm stopped playing sound: \(self.description)")
        self.state = .finished
        if let delegate = self.delegate {
            delegate.alarmNotificationDidFinish(self)
        }
    }
    
    func shouldStop(ifNotContainedIn dataModelIdentifiers: Set<String>) -> Bool {
        return !dataModelIdentifiers.contains(self.itemID)
    }
}


