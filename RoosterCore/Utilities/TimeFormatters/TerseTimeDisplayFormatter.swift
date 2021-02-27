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

    public var seconds: String { return "s" }
    
    public var minutes: String { return "m" }
    
    public var hours: String { return "h" }
    
    public var minute: String { return "m" }
    
    public var second: String { return "s" }
    
    public var hour: String { return "h" }
    
    public var delimeter: String { return "" }
    
    public var componentDelimeter: String { return ", " }
}
