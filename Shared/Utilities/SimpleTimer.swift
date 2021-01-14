//
//  Timeable.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation

class SimpleTimer : CustomStringConvertible, Loggable {
    static let RepeatEndlessly: Int = Int.max
    
    private weak var timer: Timer?
    
    private(set) var requestedFireCount: Int
    
    private(set) var fireCount: Int
    
    private(set) var isTiming: Bool
    
    private var interval: TimeInterval
    
    private var id: Int
    
    private static var idCounter:Int = 0
    
    private(set) var startDate: Date?
    
    private let name: String
    
    var logTimerEvents = true
    
    
    init(withName name: String) {
        self.timer = nil
        self.requestedFireCount = 0
        self.fireCount = 0
        self.isTiming = false
        self.interval = 0
        self.name = name
        
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
            if self.logTimerEvents {
                self.logger.log("Timer stopped: \(self.description)")
            }
          
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
    private func timerFired(completion: @escaping (_ timer: SimpleTimer) -> Void) {
        self.fireCount += 1
        
        let willFireAgain = self.willFireAgain
        
        if self.logTimerEvents {
            self.logger.log("timer fired: \(self.description), will fire again: \(willFireAgain)")
        }

        if !willFireAgain{
            self.stop()
        }
        
        completion(self)
    }
    
    private func startTimer(withNextDate date: Date,
                            completion: @escaping (_ timer: SimpleTimer) -> Void) {
        
        DispatchQueue.main.async {
            let timer = Timer(fire: date,
                              interval: self.interval,
                              repeats: true) { [weak self] (timer) in
                self?.timerFired(completion: completion)
            }
            
            self.timer = timer
            
            RunLoop.current.add(timer, forMode: .common)
            
            if self.logTimerEvents {
                self.logger.log("Started timer: \(self.description)")
            }
        }
    }
    
    func start(withInterval interval: TimeInterval,
               fireCount: Int,
               completion: @escaping (_ timer: SimpleTimer) -> Void) {
        
        self.start(withDate: Date().addingTimeInterval(interval),
                   interval: interval,
                   fireCount: fireCount,
                   completion: completion)
    }

    func start(withInterval interval: TimeInterval,
               completion: @escaping (_ timer: SimpleTimer) -> Void) {
        self.start(withInterval: interval, fireCount: 1, completion: completion)
    }

    func start(withDate date: Date,
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
        
        self.startDate = date
        self.requestedFireCount = max(fireCount, 1)
        self.fireCount = 0
        self.isTiming = true
        self.interval = interval
        
        self.startTimer(withNextDate: date,
                        completion: completion)
    }

    func start(withDate date: Date,
               completion: @escaping (_ timer: SimpleTimer) -> Void) {
        
        self.start(withDate: date,
                   interval: 0,
                   fireCount: 1,
                   completion: completion)
    }
    
    var description: String {
        
        let isValid = self.timer != nil ? "\(self.timer!.isValid)" : "nil"
        let interval = self.timer != nil ? "\(self.timer!.timeInterval)" : "nil"
        let fireDate = self.timer != nil ? "\(self.timer!.fireDate.shortDateAndTimeString)" : "nil"

        return "Timer: \(self.name):\(self.id), interval:\(self.interval), fireCount: \(self.fireCount), requestFireCount: \(self.requestedFireCount), timer: \(String(describing: self.timer )), timer is valid: \(isValid), timer interval: \(interval), timer fire date: \(fireDate)"
    }


}
