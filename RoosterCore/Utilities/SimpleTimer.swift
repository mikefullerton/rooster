//
//  Timeable.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation

public class SimpleTimer : CustomStringConvertible, CustomDebugStringConvertible, Loggable {
    
    public static let RepeatEndlessly: Int = Int.max
    
    public let name: String
    public var logTimerEvents = true
    
    private(set) public var requestedFireCount: Int
    private(set) public var fireCount: Int
    private(set) public var isTiming: Bool
    private(set) public var startDate: Date?
    private(set) public var fireDate: Date?
    
    // private
    private weak var timer: Timer?
    private static var idCounter:Int = 0
    private var interval: TimeInterval
    private var id: Int
    
    public init(withName name: String) {
        self.timer = nil
        self.requestedFireCount = 0
        self.fireCount = 0
        self.isTiming = false
        self.interval = 0
        self.name = name
        
        SimpleTimer.idCounter += 1
        self.id = SimpleTimer.idCounter
    }
    
    public var timerFireDate: Date? {
        if let timer = self.timer {
            return timer.fireDate
        }
        
        return nil
    }
    
    public var timeInterval : TimeInterval {
        if let timer = self.timer {
            return timer.timeInterval
        }
        
        return 0.0
    }
    
    public var willFireAgain: Bool {
        return self.isTiming &&
               (self.requestedFireCount == SimpleTimer.RepeatEndlessly ||
                self.fireCount < self.requestedFireCount)
    }
    
    public func stop() {
        if self.isTiming {
            if self.logTimerEvents {
                self.logger.log("Timer stopped: \(self.description)")
            }
          
            self.stopTimer()
            self.isTiming = false
            self.requestedFireCount = 0
            self.fireCount = 0
            self.interval = 0
            
            self.fireDate = nil
            self.startDate = nil
        }
    }
    
    private func stopTimer() {
        if let timer = self.timer {
            DispatchQueue.main.async {
                timer.invalidate()
            }
            self.timer = nil
        }
    }
    
    private func timerFired(completion: @escaping (_ timer: SimpleTimer) -> Void) {
        self.fireCount += 1
        
        let willFireAgain = self.willFireAgain
        
        if self.logTimerEvents {
            self.logger.log("timer fired at: \(Date().shortDateAndLongTimeString), \(self.description), will fire again: \(willFireAgain)")
        }

        if !willFireAgain{
            self.stop()
        }
        
        completion(self)
    }
    
    private func startTimer(completion: @escaping (_ timer: SimpleTimer) -> Void) {
        
        let timer = Timer(fire: self.fireDate!,
                          interval: self.interval,
                          repeats: true) { [weak self] (timer) in
            if timer === self?.timer && timer.isValid {
                self?.timerFired(completion: completion)
            } else {
                self?.logger.log("Ignoring timer: \(timer)")
            }
        }
        
        self.timer = timer

        if self.logTimerEvents {
            self.logger.log("Starting timer: \(self.description)")
        }
        
        DispatchQueue.main.async {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    public func start(withInterval interval: TimeInterval,
                      fireCount: Int,
                      completion: @escaping (_ timer: SimpleTimer) -> Void) {
        
        self.start(withDate: Date().addingTimeInterval(interval),
                   interval: interval,
                   fireCount: fireCount,
                   completion: completion)
    }

    public func start(withInterval interval: TimeInterval,
                      completion: @escaping (_ timer: SimpleTimer) -> Void) {
        self.start(withInterval: interval, fireCount: 1, completion: completion)
    }

    public func start(withDate date: Date,
                      interval: TimeInterval,
                      fireCount: Int,
                      completion: @escaping (_ timer: SimpleTimer) -> Void) {

        self.stop()
        
        if date.isEqualToOrBeforeDate(Date()) {
            if self.logTimerEvents {
                self.logger.log("Timer fired after 0 seconds")
            }
            completion(self)
            return
        }
        
        self.fireDate = date
        self.startDate = Date()
        self.requestedFireCount = max(fireCount, 1)
        self.fireCount = 0
        self.isTiming = true
        self.interval = interval
        
        self.startTimer(completion: completion)
    }

    public func start(withDate date: Date,
                      completion: @escaping (_ timer: SimpleTimer) -> Void) {
        
        self.start(withDate: date,
                   interval: 0,
                   fireCount: 1,
                   completion: completion)
    }
    
    public var debugDescription: String {
        let isValid = self.timer != nil ? "\(self.timer!.isValid)" : "nil"
        let interval = self.timer != nil ? "\(self.timer!.timeInterval)" : "nil"
        let fireDate = self.timer != nil ? "\(self.timer!.fireDate.shortDateAndLongTimeString)" : "nil"

        return "\(type(of:self)): \(self.name):\(self.id), timer fire date: \(fireDate), interval:\(self.interval), fireCount: \(self.fireCount), requestFireCount: \(self.requestedFireCount), timer: \(String(describing: self.timer )), timer is valid: \(isValid), timer interval: \(interval)"
    }
    
    public var description: String {
        let timerFireDate = self.timer != nil ? "\(self.timer!.fireDate.shortDateAndLongTimeString)" : "nil"
        let fireDate = self.fireDate != nil ? "\(self.fireDate!.shortDateAndLongTimeString)" : "nil"
        return "\(type(of:self)): \(self.name):\(self.id), started: \(self.startDate?.shortDateAndLongTimeString ?? "nil"), fire date: \(fireDate), timer fire date: \(timerFireDate)"
    }
}
