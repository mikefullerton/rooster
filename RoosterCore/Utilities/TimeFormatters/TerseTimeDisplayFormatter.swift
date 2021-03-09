//
//  ShortTimeDisplayFormatter.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/20/21.
//

import Foundation

public struct TerseTimeDisplayFormatter: TimeDisplayFormatter {
    public let showSecondsWithMinutes: TimeInterval

    public init(showSecondsWithMinutes: TimeInterval) {
        self.showSecondsWithMinutes = showSecondsWithMinutes
    }

    public var seconds: String { "s" }

    public var minutes: String { "m" }

    public var hours: String { "h" }

    public var minute: String { "m" }

    public var second: String { "s" }

    public var hour: String { "h" }

    public var delimeter: String { "" }

    public var componentDelimeter: String { ", " }
}
