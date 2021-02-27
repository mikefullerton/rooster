//
//  DigitalClockTimeDisplayFormatter.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/20/21.
//

import Foundation

public struct DigitalClockTimeDisplayFormatter: TimeDisplayFormatter {
    public let showSecondsWithMinutes: TimeInterval

    public init(showSecondsWithMinutes: TimeInterval) {
        self.showSecondsWithMinutes = showSecondsWithMinutes
    }

    public var seconds: String { return "" }
    
    public var minutes: String { return "" }
    
    public var hours: String { return "" }
    
    public var minute: String { return "" }
    
    public var second: String { return "" }
    
    public var hour: String { return "" }
    
    public var delimeter: String { return "" }
    
    public var componentDelimeter: String { return ":" }
    
    public func paddedComponent(_ component: Int) -> String {
        return String(describing: component).leftPadding(toLength: 2, withPad: "0");
    }
    
    public func displayString(withIntervalUntilFire interval: TimeInterval) -> String {
        let times = CalculatedTimes(withInterval: interval, showSecondsWithMinutesInterval: self.showSecondsWithMinutes)
        
        if times.showSeconds {
            return "\(self.paddedComponent(times.hours)):\(self.paddedComponent(times.minutes)):\(self.paddedComponent(times.seconds))"
        } else {
            return "\(self.paddedComponent(times.hours)):\(self.paddedComponent(times.minutes))"
        }
    }
}
