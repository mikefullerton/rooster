//
//  DigitalClockTimeDisplayFormatter.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/20/21.
//

import Foundation

struct DigitalClockTimeDisplayFormatter: TimeDisplayFormatter {
    let showSecondsWithMinutes: TimeInterval

    init(showSecondsWithMinutes: TimeInterval) {
        self.showSecondsWithMinutes = showSecondsWithMinutes
    }

    var seconds: String { return "" }
    
    var minutes: String { return "" }
    
    var hours: String { return "" }
    
    var minute: String { return "" }
    
    var second: String { return "" }
    
    var hour: String { return "" }
    
    var delimeter: String { return "" }
    
    var componentDelimeter: String { return ":" }
    
    func paddedComponent(_ component: Int) -> String {
        return String(describing: component).leftPadding(toLength: 2, withPad: "0");
    }
    
    func displayString(withIntervalUntilFire interval: TimeInterval) -> String {
        let times = CalculatedTimes(withInterval: interval, showSecondsWithMinutesInterval: self.showSecondsWithMinutes)
        
        if times.showSeconds {
            return "\(self.paddedComponent(times.hours)):\(self.paddedComponent(times.minutes)):\(self.paddedComponent(times.seconds))"
        } else {
            return "\(self.paddedComponent(times.hours)):\(self.paddedComponent(times.minutes))"
        }
    }
}
