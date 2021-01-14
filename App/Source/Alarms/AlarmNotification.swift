//
//  AlarmNotification.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation
import UIKit

protocol AlarmNotificationDelegate : AnyObject {
    func alarmNotificationDidStart(_ alarmNotification: AlarmNotification)
    func alarmNotificationDidFinish(_ alarmNotification: AlarmNotification)
}

class AlarmNotification: Equatable, Hashable, Loggable, CustomStringConvertible, AlarmSoundDelegate, Identifiable {
    
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
    private var sound: AlarmSound?
    
    let id: String
    let itemID: String
    
    private static var idCounter:Int = 0
    
    init(withItemIdentifier itemIdentifier: String) {
        AlarmNotification.idCounter += 1

        self.id = "(AlarmNotification.idCounter)"
        self.state = .none
        self.timer = SimpleTimer(withName: "AlarmNotificationTimer")
        self.sound = nil
        self.itemID = itemIdentifier
    }
   
    var item: CalendarItem? {
        let dataModel = DataModelController.dataModel
        return dataModel.item(forIdentifier: self.itemID)
    }
    
    private func performStartActions() {

        if let item = self.item {
            self.logger.log("performing start actions for \(self.description)")
            let prefs = PreferencesController.instance.preferences
            
            if prefs.autoOpenLocations {
                self.logger.log("auto opening location URL (if available) for \(self.description)")
                
                item.openLocationURL()
            }
            
            if prefs.useSystemNotifications {
                self.logger.log("posting system notifications for \(self.description)")

                UserNotificationCenterController.instance.scheduleNotification(forItem: item)
            }
            
            #if targetEnvironment(macCatalyst)
            if prefs.bounceIconInDock {
                self.logger.log("bouncing app in dock for \(self.description)")

                AppKitPluginController.instance.utilities.startBouncingAppIcon()
            }
            #endif
        
        // Do we want this since you can just click in the menubar now?
        //        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
        //            AppKitPlugin.instance.bringAppToFront()
        //        }
        }
    }
    
    private func startPlayingSound() {
        
        
        let itemPrefs = PreferencesController.instance.preferences(forItemIdentifier: self.itemID)
        
        let sound = AlarmSoundGroup(withPreference: itemPrefs.soundPreference)
        sound.delegate = self
        self.sound = sound
        
        let soundPrefs = itemPrefs.soundPreference
        
        let soundBehavior = AlarmSoundBehavior(playCount: soundPrefs.playCount,
                                               timeBetweenPlays: 0.1,
                                               fadeInTime: 0)
        
        let interval = TimeInterval(soundPrefs.startDelay)
        
        self.logger.log("starting alarm sound for \(self.description), with interval: \(interval)")

        self.timer.start(withInterval:interval) { (timer) in
            
            self.logger.log("playing alarm sound: \(sound.name) for \(self.description)")

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
        return "AlarmNotification: \(self.id), itemID: \(self.itemID), state: \(self.state.rawValue)"
    }
    
    func soundWillStartPlaying(_ sound: AlarmSound) {
    }
    
    func soundDidStopPlaying(_ sound: AlarmSound) {
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


