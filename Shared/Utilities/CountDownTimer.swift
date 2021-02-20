//
//  Date+TimeDisplayFormatter.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/7/21.
//

import Foundation

protocol CountDownDelegate: AnyObject {
    func countdown(_ countDown: CountDownTimer, didUpdate displayString: String)
    func countdown(_ countDown: CountDownTimer, didFinish displayString: String)
    func countdownDisplayFormatter(_ countDown: CountDownTimer) -> TimeDisplayFormatter
    func countdownFireDate(_ countDown: CountDownTimer) -> Date? // returning nil stops countdown
    func countdown(_ countDown: CountDownTimer, willStart: Bool)
}

class CountDownTimer: Loggable {
    
    weak var delegate: CountDownDelegate? = nil
    
    private let timer = SimpleTimer(withName: "CountDown")
    
    private var isCounting: Bool = false
    
    private(set) var isCountingDown: Bool {
        get {
            return self.isCounting;
        }
        
        set(counting) {
            if counting != self.isCounting {
                self.isCounting = counting
                
                if !self.isCounting {
                    if let delegate = self.delegate {
                        delegate.countdown(self, didFinish: "")
                    }
                    self.timer.stop()
                }

            }
        }
    }
    
    init() {
    }
    
    init(withDelegate delegate: CountDownDelegate) {
        self.delegate = delegate
    }
    
    var fireDate: Date {
        if let delegate = self.delegate,
           let fireDate = delegate.countdownFireDate(self) {
            return fireDate
        }
        
        return Date()
    }
    
    private var displayFormatter:TimeDisplayFormatter {
        if let delegate = self.delegate {
            return delegate.countdownDisplayFormatter(self)
        }

        return TerseTimeDisplayFormatter(showSecondsWithMinutes: 2)
    }
    
    var displayString: String {
        return self.displayFormatter.displayString(withIntervalUntilFire: self.intervalUntilFire)
    }
    
    var intervalUntilFire: TimeInterval {
        self.intervalUntilFireDate(self.fireDate)
    }
    
    private func intervalUntilFireDate(_ fireDate: Date) -> TimeInterval {
        let fireTime = fireDate.timeIntervalSinceReferenceDate
        let nowInterval = Date().timeIntervalSinceReferenceDate
        return fireTime - nowInterval
    }
    
    func update() {
        self.timer.stop()
        if let delegate = self.delegate {
            
            let interval = self.intervalUntilFire
            if interval > 0 {
                
                if !self.isCountingDown {
                    delegate.countdown(self, willStart: true)
                }
                
                self.isCountingDown = true
                delegate.countdown(self, didUpdate: self.displayFormatter.displayString(withIntervalUntilFire: interval))

                // this will be either 1 minute or 1 second
                let date = self.calculateNextTimerFireDate()
                self.timer.start(withDate: date) { [weak self] timer in
                    self?.update()
                }
            } else {
                self.isCountingDown = false
            }
        } else {
            self.isCountingDown = false
        }
    }
    
    private func calculateNextTimerFireDate() -> Date {
        
        let fastInterval = self.displayFormatter.showSecondsWithMinutes * 60
        
        let fireDate = self.fireDate
        let fastFireTime = fireDate.addingTimeInterval( -fastInterval )
        let now = Date()
        
        if fastFireTime.isEqualToOrBeforeDate(now) {
            return now.addingTimeInterval(1.0)
        }
        
        let futureDate = now.addingTimeInterval(60.0)
        return futureDate.dateWithoutSeconds
    }
    
    func start() {
        self.logger.log("Starting countdown until: \(self.fireDate.shortDateAndLongTimeString)")
        self.update()
        
        if !self.isCountingDown,
           let delegate = self.delegate {
            delegate.countdown(self, willStart: false)
        }
    }
    
    func stop() {
        self.isCountingDown = false
    }
    
}
