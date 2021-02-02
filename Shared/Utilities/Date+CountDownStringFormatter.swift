//
//  Date+CountDownStringFormatter.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/7/21.
//

import Foundation

protocol CountDownStringFormatter {
    var seconds: String { get }
    var minutes: String { get }
    var hours: String { get }
    var minute: String { get }
    var second: String { get }
    var hour: String { get }
    var delimeter: String { get }
    var componentDelimeter: String { get }
    
    var showSecondsWithMinutes: TimeInterval { get }
}

extension CountDownStringFormatter {
    func secondsString(_ seconds: Int) -> String {
        if seconds == 1 {
            return "\(seconds)\(self.delimeter)\(self.second)"
        } else {
            return "\(seconds)\(self.delimeter)\(self.seconds)"
        }
    }
    func minutesString(_ minutes: Int) -> String {
        if minutes == 1 {
            return "\(minutes)\(self.delimeter)\(self.minute)"
        } else {
            return "\(minutes)\(self.delimeter)\(self.minutes)"
        }
    }
    func hoursString(_ hours: Int) -> String {
        if hours == 1 {
            return "\(hours)\(self.delimeter)\(self.hour)"
        } else {
            return "\(hours)\(self.delimeter)\(self.hours)"
        }
    }
    
    func displayString(withIntervalUntilFire interval: TimeInterval) -> String {
        var text = ""
    
        if interval > 0 {

            let minutes = interval / (60.0)
            
            let hours = floor(interval / (60.0 * 60.0))

            let showSeconds = self.showSecondsWithMinutes > 0 && self.showSecondsWithMinutes >= minutes
            
            let displayMinutes = showSeconds ?
                                    floor((interval - (hours * 60 * 60)) / 60) :
                                    round((interval - (hours * 60 * 60)) / 60)
            
            let displaySeconds = interval - (hours * 60 * 60) - (floor(minutes) * 60)
    
            var shouldDisplaySeconds = false
            if hours > 0 {
                
                text += self.hoursString(Int(hours))
                if displayMinutes > 1 {
                    text += self.componentDelimeter + self.minutesString(Int(displayMinutes))
                }
            } else if displayMinutes > 0 {
                text += self.minutesString(Int(displayMinutes))
                shouldDisplaySeconds = showSeconds

                if shouldDisplaySeconds {
                    text += self.componentDelimeter
                }
            } else {
                shouldDisplaySeconds = true
            }
            
            if shouldDisplaySeconds {
                text += self.secondsString(Int(displaySeconds))
            }
        }
    
        return text
    }
}

struct LongCountDownStringFormatter: CountDownStringFormatter {
    let showSecondsWithMinutes: TimeInterval
    
    init(showSecondsWithMinutes: TimeInterval) {
        self.showSecondsWithMinutes = showSecondsWithMinutes
    }
    
    var seconds: String { return "seconds" }
    
    var minutes: String { return "minutes" }
    
    var hours: String { return "hours" }
    
    var minute: String { return "minute" }
    
    var second: String { return "second" }
    
    var hour: String { return "hour" }
    
    var delimeter: String { return " " }
    
    var componentDelimeter: String { return ", " }
}

struct ShortCountDownStringFormatter: CountDownStringFormatter {
    let showSecondsWithMinutes: TimeInterval

    init(showSecondsWithMinutes: TimeInterval) {
        self.showSecondsWithMinutes = showSecondsWithMinutes
    }

    var seconds: String { return "s" }
    
    var minutes: String { return "m" }
    
    var hours: String { return "h" }
    
    var minute: String { return "m" }
    
    var second: String { return "s" }
    
    var hour: String { return "h" }
    
    var delimeter: String { return "" }
    
    var componentDelimeter: String { return ", " }
}

protocol CountDownDelegate: AnyObject {
    func countdown(_ countDown: CountDown, didUpdate displayString: String)
    func countdown(_ countDown: CountDown, didFinish displayString: String)
    func countdownDisplayFormatter(_ countDown: CountDown) -> CountDownStringFormatter
    func countdownFireDate(_ countDown: CountDown) -> Date? // returning nil stops countdown
    func countdown(_ countDown: CountDown, willStart: Bool)
}

class CountDown: Loggable {
    
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
    
    private var displayFormatter:CountDownStringFormatter {
        if let delegate = self.delegate {
            return delegate.countdownDisplayFormatter(self)
        }

        return ShortCountDownStringFormatter(showSecondsWithMinutes: 2)
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
                let timerInterval = self.calculateNextTimerFireInterval(intervalUntilFireDate: interval)
                self.timer.start(withInterval: timerInterval) { [weak self] timer in
                    self?.update()
                }
            } else {
                self.isCountingDown = false
            }
        } else {
            self.isCountingDown = false
        }
    }
    
    private func calculateNextTimerFireInterval(intervalUntilFireDate: TimeInterval) -> TimeInterval {
        
        let formatter = self.displayFormatter
        
        if formatter.showSecondsWithMinutes >= 0 {
            let startOfFastCoundown = intervalUntilFireDate - (formatter.showSecondsWithMinutes * 60)
        
            if startOfFastCoundown <= 6 {
                return 1.0
            }
            
            return min(60.0, intervalUntilFireDate)
        }
        
        return min(60.0, intervalUntilFireDate)
    }
    
    func start() {
        
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
