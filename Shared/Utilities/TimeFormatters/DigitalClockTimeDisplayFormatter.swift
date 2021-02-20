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

    var seconds: String { return "s" }
    
    var minutes: String { return "m" }
    
    var hours: String { return "h" }
    
    var minute: String { return "m" }
    
    var second: String { return "s" }
    
    var hour: String { return "h" }
    
    var delimeter: String { return "" }
    
    var componentDelimeter: String { return ", " }
}
