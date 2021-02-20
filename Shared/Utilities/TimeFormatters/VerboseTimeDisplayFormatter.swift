//
//  LongTimeDisplayFormatter.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/20/21.
//

import Foundation

struct VerboseTimeDisplayFormatter: TimeDisplayFormatter {
    let showSecondsWithMinutes: TimeInterval
    
    init(showSecondsWithMinutes: TimeInterval) {
        self.showSecondsWithMinutes = showSecondsWithMinutes
    }
    
    var seconds: String { return "seconds" }
    
    var minutes: String { return "minutes" }
    
    var hours: String { return "hours" }
    
    var minute: String { return "minute" }
    
    var second: String { return "second" }
    
    var hour: String { return "hour" }
    
    var delimeter: String { return " " }
    
    var componentDelimeter: String { return ", " }
}
