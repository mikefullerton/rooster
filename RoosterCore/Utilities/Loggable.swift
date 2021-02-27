//
//  Loggable.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation
import OSLog

public protocol Loggable {
    
}

extension Loggable {
    
    public static var logger : Logger {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "nil"
        let category = "\(type(of: self))".replacingOccurrences(of: ".Type", with: "")
        return Logger(subsystem: bundleIdentifier, category: category)
    }
    
    public var logger: Logger {
        return type(of: self).logger
    }
}
