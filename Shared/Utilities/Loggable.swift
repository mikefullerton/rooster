//
//  Loggable.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation
import OSLog

protocol Loggable {
    
}

extension Loggable {
    
    static var logger : Logger {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "nil"
        let category = "\(type(of: self))".replacingOccurrences(of: ".Type", with: "")
        return Logger(subsystem: bundleIdentifier, category: category)
    }
    
    var logger: Logger {
        return type(of: self).logger
    }
}
