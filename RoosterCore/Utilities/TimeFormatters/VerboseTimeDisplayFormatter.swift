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
    
    public var seconds: String { return "seconds" }
    
    public var minutes: String { return "minutes" }
    
    public var hours: String { return "hours" }
    
    public var minute: String { return "minute" }
    
    public var second: String { return "second" }
    
    public var hour: String { return "hour" }
    
    public var delimeter: String { return " " }
    
    public var componentDelimeter: String { return ", " }
}
