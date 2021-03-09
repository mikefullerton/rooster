//
//  EventPreferences.swift
//  RoosterCore-macOS
//
//  Created by Mike Fullerton on 3/26/21.
//

import Foundation

public struct EventPreferences: Equatable, Codable, CustomStringConvertible {
    
    public var description: String {
        return """
        type(of:self)
        """
    }
    
    public static var `default`: EventPreferences {
        return EventPreferences()
    }
}
