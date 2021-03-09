//
//  LongTimeDisplayFormatter.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/20/21.
//

import Foundation

public struct VerboseTimeDisplayFormatter: TimeDisplayFormatter {
    public let showSecondsWithMinutes: TimeInterval

    public init(showSecondsWithMinutes: TimeInterval) {
        self.showSecondsWithMinutes = showSecondsWithMinutes
    }

    public var seconds: String { "seconds" }

    public var minutes: String { "minutes" }

    public var hours: String { "hours" }

    public var minute: String { "minute" }

    public var second: String { "second" }

    public var hour: String { "hour" }

    public var delimeter: String { " " }

    public var componentDelimeter: String { ", " }
}
