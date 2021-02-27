//
//  SparkleTimer.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/20/21.
//

import Foundation
import RoosterCore

protocol SparkleTimerDelegate : AnyObject {
    func sparkleTimerCheckForUpdates(_ timer: SparkleTimer)
}

class SparkleTimer : Loggable {
    
    weak var delegate: SparkleTimerDelegate?
    
    private var timer: SimpleTimer
    let nextUpdateCheckDateKey = "nextUpdateCheckDateKey"
    let lastUpdateCheckDateKey = "lastUpdateCheckDateKey"
    let tryAgainInterval:TimeInterval = 60 * 60
    let updateCheckInterval: TimeInterval = 60 * 60 * 24

    init(withDelegate delegate: SparkleTimerDelegate?) {
        self.delegate = delegate
        self.timer = SimpleTimer(withName: "SparkleTimer")
    }
        
    var nextCheckDate: Date {
        get {
            if let date = UserDefaults.standard.object(forKey: self.nextUpdateCheckDateKey) as? Date {
                return date
            }
            
            return Date()
        }
        set(newDate) {
            UserDefaults.standard.setValue(newDate, forKey: self.nextUpdateCheckDateKey)
        }
    }
    
    var lastUpdateCheckDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: self.lastUpdateCheckDateKey) as? Date
        }
        set(newDate) {
            if newDate == nil {
                UserDefaults.standard.removeObject(forKey: self.lastUpdateCheckDateKey)
            } else {
                UserDefaults.standard.setValue(newDate, forKey: self.lastUpdateCheckDateKey)
            }
        }
    }
   
    func removeNextCheckDate() {
        UserDefaults.standard.removeObject(forKey: self.nextUpdateCheckDateKey)
    }

    var isTimeForUpdate: Bool {
        return self.nextCheckDate.isEqualToOrBeforeDate(Date())
    }

    func startNextCheckTimer() {
        self.logger.log("Starting next check timer at \(Date().shortDateAndTimeString), will check again at \(self.nextCheckDate.shortDateAndTimeString)")
        self.timer.start(withDate: self.nextCheckDate) { [weak self] timer in
            if let strongSelf = self {
                strongSelf.logger.log("Timer expired, will check for updates if needed")
                strongSelf.delegate?.sparkleTimerCheckForUpdates(strongSelf)
            }
        }
    }
    
    func didSuccessfullyCheck() {
        self.lastUpdateCheckDate = Date()
        self.nextCheckDate = Date().addingTimeInterval(self.updateCheckInterval)
        self.logger.log("Did succussfully check for updates.")
        self.startNextCheckTimer()
    }
    
    func didFailCheck() {
        self.nextCheckDate = Date().addingTimeInterval(self.tryAgainInterval)
        self.logger.log("Did fail check for updates, will try again in \( Int(self.tryAgainInterval / 60)) minutes")
        self.startNextCheckTimer()
    }
   
    func stop() {
        self.timer.stop()
    }
}
