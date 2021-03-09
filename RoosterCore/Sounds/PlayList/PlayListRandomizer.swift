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
    
    public struct Behavior: DescribeableOptionSet {

        public let rawValue: Int
        
        public static var zero                                      = Behavior([])
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

    }
}






