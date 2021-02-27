//
//  TimeDisplayFormatter.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/20/21.
//

import Foundation

public protocol TimeDisplayFormatter {
    var seconds: String { get }
    var minutes: String { get }
    var hours: String { get }
    var minute: String { get }
    var second: String { get }
    var hour: String { get }
    var delimeter: String { get }
    var componentDelimeter: String { get }
    
    var showSecondsWithMinutes: TimeInterval { get }
    
    func displayString(withIntervalUntilFire interval: TimeInterval) -> String
}


struct CalculatedTimes {
    var minutes: Int
    var seconds: Int
    var hours: Int
    var showSeconds: Bool
    
    init(withInterval interval: TimeInterval,
         showSecondsWithMinutesInterval: TimeInterval) {
        
        let minutesInterval = interval / (60.0)
        
        let showSeconds = showSecondsWithMinutesInterval > 0 && showSecondsWithMinutesInterval >= minutesInterval
        
        let hours = floor(interval / (60.0 * 60.0))
        
        let truncatedSeconds = hours * 60 * 60
        
        let truncatedMinutes = ((interval - truncatedSeconds) / 60)
        
        let minutes = showSeconds ? floor(truncatedMinutes) : round(truncatedMinutes)
        
        let seconds = interval - (truncatedSeconds) - (floor(minutes) * 60)
        
        self.showSeconds = showSeconds
        self.minutes = Int(minutes)
        self.hours = Int(hours)
        self.seconds = Int(seconds)
    }
}

extension TimeDisplayFormatter {
    public func secondsString(_ seconds: Int) -> String {
        if seconds == 1 {
            return "\(seconds)\(self.delimeter)\(self.second)"
        } else {
            return "\(seconds)\(self.delimeter)\(self.seconds)"
        }
    }
    
    public func minutesString(_ minutes: Int) -> String {
        if minutes == 1 {
            return "\(minutes)\(self.delimeter)\(self.minute)"
        } else {
            return "\(minutes)\(self.delimeter)\(self.minutes)"
        }
    }
    
    public func hoursString(_ hours: Int) -> String {
        if hours == 1 {
            return "\(hours)\(self.delimeter)\(self.hour)"
        } else {
            return "\(hours)\(self.delimeter)\(self.hours)"
        }
    }
    
    public func displayString(withIntervalUntilFire interval: TimeInterval) -> String {
        var text = ""
    
        if interval > 0 {

            let times = CalculatedTimes(withInterval: interval, showSecondsWithMinutesInterval: self.showSecondsWithMinutes)
            
            var shouldDisplaySeconds = false
            if times.hours > 0 {
                text += self.hoursString(times.hours)
                if times.minutes > 1 {
                    text += self.componentDelimeter + self.minutesString(times.minutes)
                }
            } else if times.minutes > 0 {
                text += self.minutesString(times.minutes)
                shouldDisplaySeconds = times.showSeconds

                if shouldDisplaySeconds {
                    text += self.componentDelimeter
                }
            } else {
                shouldDisplaySeconds = true
            }
            
            if shouldDisplaySeconds {
                text += self.secondsString(times.seconds)
            }
        }
    
        return text
    }
}
