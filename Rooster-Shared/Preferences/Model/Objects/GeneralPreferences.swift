//
//  GeneralPreferences.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

public struct GeneralPreferences: CustomStringConvertible, Loggable, Codable, Equatable {
 
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

extension GeneralPreferences {
    
    public static let `default` = GeneralPreferences()
    
    public struct Options: DescribeableOptionSet {
        
        public let rawValue: Int
        
        public static var zero                 = Options([])
        public static let automaticallyLaunch  = Options(rawValue: 1 << 1)

        public static let all: Options = [ .automaticallyLaunch ]

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    
        public static var descriptions: [(Self, String)] = [
            (.automaticallyLaunch, "automaticallyLaunch")
        ]
    }

}
