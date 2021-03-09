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

    public var seconds: String { "" }

    public var minutes: String { "" }

    public var hours: String { "" }

    public var minute: String { "" }

    public var second: String { "" }

    public var hour: String { "" }

    public var delimeter: String { "" }

    public var componentDelimeter: String { ":" }

    public func paddedComponent(_ component: Int) -> String {
        String(describing: component).leftPadding(toLength: 2, withPad: "0")
    }

    public func displayString(withIntervalUntilFire interval: TimeInterval) -> String {
        let times = CalculatedTimes(withInterval: interval, showSecondsWithMinutesInterval: self.showSecondsWithMinutes)

        if times.showSeconds {
            return "\(self.paddedComponent(times.hours)):\(self.paddedComponent(times.minutes)):\(self.paddedComponent(times.seconds))"
        } else {
            return "\(self.paddedComponent(times.hours)):\(self.paddedComponent(times.minutes))"
        }
    }

    public static var instance = DigitalClockTimeDisplayFormatter(showSecondsWithMinutes: 0)

    public static func formattedInterval(_ interval: TimeInterval) -> String {
        Self.instance.displayString(withIntervalUntilFire: interval)
    }
}
