//
//  Timeable.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation
import OSLog

class SimpleTimer : CustomStringConvertible {
    
    static let logger = Logger(subsystem: "com.apple.rooster", category: "SimpleTimer")
    var logger: Logger {
        return type(of: self).logger
    }
 
    static let RepeatEndlessly: Int = Int.max
    
    private weak var timer: Timer?
    
    private(set) var requestedFireCount: Int
    
    private(set) var fireCount: Int
    
    private(set) var isTiming: Bool
    
    private var interval: TimeInterval
    
    private var id: Int
    
    private static var idCounter:Int = 0
    
    init() {
        self.timer = nil
        self.requestedFireCount = 0
        self.fireCount = 0
        self.isTiming = false
        self.interval = 0
        
        SimpleTimer.idCounter += 1
        self.id = SimpleTimer.idCounter
    }
    
    var fireDate: Date? {
        if let timer = self.timer {
            return timer.fireDate
        }
        
        return nil
    }
    
    var timeInterval : TimeInterval {
        if let timer = self.timer {
            return timer.timeInterval
        }
        
        return 0.0
    }
    
    var willFireAgain: Bool {
        return self.isTiming &&
               (self.requestedFireCount == SimpleTimer.RepeatEndlessly ||
                self.fireCount < self.requestedFireCount)
    }
    
    func stop() {
        if self.isTiming {
            self.logger.log("Timer stopped: \(self.description)")
          
            self.stopTimer()
            self.isTiming = false
            self.requestedFireCount = 0
            self.fireCount = 0
            self.interval = 0
        }
    }
    
    private func stopTimer() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    private func startTimer(completion: @escaping (_ timer: SimpleTimer) -> Void) {
        
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: self.interval, repeats: false) { (timer) in
                self.stopTimer()
                self.logger.log("timer fired: \(self.description)")

                self.fireCount += 1
                if self.willFireAgain {
                    self.logger.log("Rescheduling timer: \(self.description)")
                    self.startTimer(completion: completion)
                } else {
                    self.stop()
                }
                
                completion(self)
            }
            
            self.logger.log("scheduled timer: \(self.description)")
        }
    }
    
    func start(withInterval interval: TimeInterval,
               playCount: Int,
               completion: @escaping (_ timer: SimpleTimer) -> Void) {
        
        self.stop()
        
        self.requestedFireCount = playCount
        self.fireCount = 0
        self.isTiming = true
        self.interval = interval

        if !self.willFireAgain {
            self.stop()
            self.logger.error("Invalid timer: \(self.description)")
            completion(self)
            return
        }
        
        self.logger.log("Starting timer: \(self.description)")
      
        self.startTimer(completion: completion)
    }

    func start(withInterval interval: TimeInterval,
               completion: @escaping (_ timer: SimpleTimer) -> Void) {
        self.start(withInterval: interval, playCount: 1, completion: completion)
    }

    func start(withplayCount playCount: Int,
               completion: @escaping (_ timer: SimpleTimer) -> Void) {
        self.start(withInterval: 0, playCount: playCount, completion: completion)
    }

    func start(completion: @escaping (_ timer: SimpleTimer) -> Void) {
        self.start(withInterval: 0, playCount: 1, completion: completion)
    }

    func start(withDate date: Date,
               playCount: Int,
               completion: @escaping (_ timer: SimpleTimer) -> Void) {
        
        let fireTime = date.timeIntervalSinceReferenceDate
        let now = Date().timeIntervalSinceReferenceDate
        
        let fireInterval = fireTime - now
    
        self.start(withInterval: fireInterval,
                   playCount: playCount,
                   completion: completion)
    }

    func start(withDate date: Date,
               completion: @escaping (_ timer: SimpleTimer) -> Void) {
        
        self.start(withDate: date, playCount: 1, completion: completion)
    }
    
    var description: String {
        
        let isValid = self.timer != nil ? "\(self.timer!.isValid)" : "nil"
        let interval = self.timer != nil ? "\(self.timer!.timeInterval)" : "nil"
        let fireDate = self.timer != nil ? "\(self.timer!.fireDate)" : "nil"

        return "Timer: \(self.id), interval:\(self.interval), fireCount: \(self.fireCount), requestFireCount: \(self.requestedFireCount), timer: \(String(describing: self.timer )), timer is valid: \(isValid), timer interval: \(interval), timer fire date: \(fireDate)"
    }


}
