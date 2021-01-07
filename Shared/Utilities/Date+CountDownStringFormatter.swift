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
}

struct LongCountDownStringFormatter: CountDownStringFormatter {
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
    var seconds: String { return "s" }
    
    var minutes: String { return "m" }
    
    var hours: String { return "h" }
    
    var minute: String { return "m" }
    
    var second: String { return "s" }
    
    var hour: String { return "h" }
    
    var delimeter: String { return "" }
    
    var componentDelimeter: String { return ", " }
}

struct CountDown {
    let fireDate: Date
    private(set) var intervalUntilFire: TimeInterval = 0
    let formatter: CountDownStringFormatter
    let showSecondsWithMinutes: Bool
    
    init(withFireDate fireDate: Date,
         formatter: CountDownStringFormatter,
         showSecondsWithMinutes: Bool) {
        
        self.formatter = formatter
        self.showSecondsWithMinutes = showSecondsWithMinutes
        self.fireDate = fireDate
        
        self.updateFireIntervale()
    }
    
    mutating func updateFireIntervale() {
        let fireTime = self.fireDate.timeIntervalSinceReferenceDate
        let nowInterval = Date().timeIntervalSinceReferenceDate
        self.intervalUntilFire = fireTime - nowInterval
    }
    
    var displayString: String {
        var text = ""
        
        let interval = self.intervalUntilFire
        if interval > 0 {

            let minutes = interval / (60.0)
            
            let hours = floor(interval / (60.0 * 60.0))

            let displayMinutes = self.showSecondsWithMinutes ?
                                    floor((interval - (hours * 60 * 60)) / 60) :
                                    round((interval - (hours * 60 * 60)) / 60)
            
            let displaySeconds = interval - (hours * 60 * 60) - (floor(minutes) * 60)
    
            var shouldDisplaySeconds = false
            if hours > 0 {
                
                text += self.formatter.hoursString(Int(hours))
                if displayMinutes > 1 {
                    text += self.formatter.componentDelimeter + self.formatter.minutesString(Int(displayMinutes))
                }
            } else if displayMinutes > 0 {
                text += self.formatter.minutesString(Int(displayMinutes))
                shouldDisplaySeconds = self.showSecondsWithMinutes

                if shouldDisplaySeconds {
                    text += self.formatter.componentDelimeter
                }
            } else {
                shouldDisplaySeconds = true
            }
            
            if shouldDisplaySeconds {
                text += self.formatter.secondsString(Int(displaySeconds))
            }
        }
        
        return text
    }
}
