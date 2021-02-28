//
//  SoundSetRandomizer.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/8/21.
//

import Foundation

public struct PlayListRandomizer: Loggable, Codable, CustomStringConvertible, Equatable {
    
    public var behavior: Behavior
    
    private init() {
        self.behavior = []
    }
    
    public init(withBehavior behavior: Behavior) {
        self.behavior = behavior
    }
    
    public static var `default` = PlayListRandomizer()
    
    public var description: String {
        return """
        \(type(of:self)): \
        behavior: \(self.behavior.description)
        """
    }

    public static func == (lhs: PlayListRandomizer, rhs: PlayListRandomizer) -> Bool {
        return  lhs.behavior == rhs.behavior
    }
}

extension PlayListRandomizer {
    
    public struct Behavior: OptionSet, CustomStringConvertible, Codable, Equatable {
        
        public let rawValue: Int
        
        public static let randomizeOrder                            = Behavior(rawValue: 1 << 1)
        public static let regenerateEachPlay                        = Behavior(rawValue: 1 << 2)

        public static let all: Behavior = [
            .randomizeOrder, .regenerateEachPlay
        ]

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static var descriptions: [(Self, String)] = [
            (.randomizeOrder, "randomizeOrder"),
            (.regenerateEachPlay, "regenerateEachPaly"),
        ]

        public var description: String {
            let result: [String] = Self.descriptions.filter { contains($0.0) }.map { $0.1 }
            return "\(type(of:self)): (rawValue: \(self.rawValue)) [\(result.joined(separator:", "))]"
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }

    }
}






