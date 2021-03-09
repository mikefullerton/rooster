//
//  CalculatedTimes.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/6/21.
//

import Foundation

internal struct CalculatedTimes {
    var minutes: Int
    var seconds: Int
    var hours: Int
    var showSeconds: Bool

    init(withInterval interval: TimeInterval,
         showSecondsWithMinutesInterval: TimeInterval) {
        let minutesInterval = interval / (60.0)

        let showSeconds = showSecondsWithMinutesInterval == 0 || showSecondsWithMinutesInterval >= minutesInterval

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
