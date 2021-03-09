//
//  SparkleTimer.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/20/21.
//

import Foundation
import RoosterCore

public protocol SparkleTimerDelegate : AnyObject {
    func sparkleTimerCheckForUpdates(_ timer: SparkleTimer)
}

public class SparkleTimer : Loggable {
    
    public weak var delegate: SparkleTimerDelegate?
    
    private var timer: SimpleTimer
    let nextUpdateCheckDateKey = "nextUpdateCheckDateKey"
    let lastUpdateCheckDateKey = "lastUpdateCheckDateKey"
    let tryAgainInterval:TimeInterval = 60 * 60
    let updateCheckInterval: TimeInterval = 60 * 60 * 24

    public init(withDelegate delegate: SparkleTimerDelegate?) {
        self.delegate = delegate
        self.timer = SimpleTimer(withName: "SparkleTimer")
    }
        
    public var nextCheckDate: Date {
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
    
    public var lastUpdateCheckDate: Date? {
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
   
    public func removeNextCheckDate() {
        UserDefaults.standard.removeObject(forKey: self.nextUpdateCheckDateKey)
    }

    public var isTimeForUpdate: Bool {
        return self.nextCheckDate.isEqualToOrBeforeDate(Date())
    }

    public func startNextCheckTimer() {
        self.logger.log("Starting next check timer at \(Date().shortDateAndTimeString), will check again at \(self.nextCheckDate.shortDateAndTimeString)")
        self.timer.start(withDate: self.nextCheckDate) { [weak self] _ in
            if let strongSelf = self {
                strongSelf.logger.log("Timer expired, will check for updates if needed")
                strongSelf.delegate?.sparkleTimerCheckForUpdates(strongSelf)
            }
        }
    }
    
    public func didSuccessfullyCheck() {
        self.lastUpdateCheckDate = Date()
        self.nextCheckDate = Date().addingTimeInterval(self.updateCheckInterval)
        self.logger.log("Did succussfully check for updates.")
        self.startNextCheckTimer()
    }
    
    public func didFailCheck() {
        self.nextCheckDate = Date().addingTimeInterval(self.tryAgainInterval)
        self.logger.log("Did fail check for updates, will try again in \( Int(self.tryAgainInterval / 60)) minutes")
        self.startNextCheckTimer()
    }
   
    public func stop() {
        self.timer.stop()
    }
}
