//
//  CalendarPreferences.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/25/21.
//

import Foundation
import RoosterCore

public struct CalendarPreferences: CustomStringConvertible, Loggable, Codable, Equatable {
 
    public var options: Options
    
    public init() {
        self.options = .all
    }
    
    public var description: String {
        return """
        "\(type(of:self)): \
        Options: \(self.options.description)
        """
    }
}

extension CalendarPreferences {
    
    public static let `default` = CalendarPreferences()
    
    public struct Options: DescribeableOptionSet {
        
        public let rawValue: Int
        
        public static var zero                 = Options([])
        public static let showCalendarName     = Options(rawValue: 1 << 1)

        public static let all: Options = [ .showCalendarName ]

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    
        public static var descriptions: [(Self, String)] = [
            ( .showCalendarName, "showCalendarName")
        ]
    }

}
