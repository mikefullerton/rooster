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
    public static var subsystem: String {
        Bundle.main.bundleIdentifier ?? "nil"
    }

    public static var category: String {
        "\(type(of: self))".replacingOccurrences(of: ".Type", with: "")
    }

    public static var logger: Logger {
        Logger(subsystem: self.subsystem, category: self.category)
    }

    public var logger: Logger {
        Self.logger
    }
}
