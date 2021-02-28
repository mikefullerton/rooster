//
//  GeneralPreferences.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

public struct GeneralPreferences: CustomStringConvertible, Loggable, Codable {
 
    private var timestamp: Date

    public var options: Options  {
        didSet { self.updateTimestamp() }
    }
    
    public init() {
        self.timestamp = Date()
        self.options = .all
    }
    
    public var description: String {
        return """
        "\(type(of:self)): \
        timestamp: \(self.timestamp.shortDateAndLongTimeString), \
        Options: \(self.options.description)
        """
    }
    
    private mutating func updateTimestamp() {
        self.timestamp = Date()
    }
}

extension GeneralPreferences {
    
    public static let `default` = GeneralPreferences()
    
    public struct Options: OptionSet, CustomStringConvertible, Codable {
        public let rawValue: Int
        
        public static let automaticallyLaunch  = Options(rawValue: 1 << 1)

        public static let all: Options = [ .automaticallyLaunch ]

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    
        public static var descriptions: [(Self, String)] = [
            (.automaticallyLaunch, "automaticallyLaunch")
        ]

        public var description: String {
            let result: [String] = Self.descriptions.filter { contains($0.0) }.map { $0.1 }
            return "\(type(of:self)): (rawValue: \(self.rawValue)) [\(result.joined(separator:", "))]"
        }
    }

}
