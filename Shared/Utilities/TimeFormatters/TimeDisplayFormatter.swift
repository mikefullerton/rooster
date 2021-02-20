//
//  TimeDisplayFormatter.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/20/21.
//

import Foundation

protocol TimeDisplayFormatter {
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

extension TimeDisplayFormatter {
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
