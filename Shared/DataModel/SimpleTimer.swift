//
//  Timeable.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation

class SimpleTimer {
    
    static let RepeatEndlessly: Int = 0
    
    private weak var timer: Timer?
    
    private(set) var requestedFireCount: Int
    
    private(set) var fireCount: Int
    
    private(set) var isTiming: Bool
    
    init() {
        self.timer = nil
        self.requestedFireCount = 0
        self.fireCount = 0
        self.isTiming = false
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
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        self.isTiming = false
        self.requestedFireCount = 0
        self.fireCount = 0
    }
    
    func start(withInterval interval: TimeInterval,
               playCount: Int,
               completion: @escaping (_ timer: SimpleTimer) -> Void) {
        
        self.stop()
        
        self.requestedFireCount = playCount
        self.fireCount = 0
        self.isTiming = true
        
        if !self.willFireAgain {
            self.stop()
            completion(self)
            return
        }
        
        weak var weakSelf = self
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { (timer) in
            if let strongSelf = weakSelf {
                
                strongSelf.fireCount += 1
                if !strongSelf.willFireAgain {
                    strongSelf.stop()
                }

                completion(strongSelf)
                
            } else {
                // we went away but the timer was still going
                timer.invalidate()
            }
        }
        
        self.timer = timer
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


}
