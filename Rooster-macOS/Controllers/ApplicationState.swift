//
//  ApplicationState.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

public struct ApplicationState: OptionSet, CustomStringConvertible {
    
    public let rawValue: Int
    
    public static let microphoneOn     = ApplicationState(rawValue: 1 << 2)
    public static let cameraOn         = ApplicationState(rawValue: 1 << 3)
    public static let sleeping         = ApplicationState(rawValue: 1 << 4)
    public static let locked           = ApplicationState(rawValue: 1 << 6)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static var descriptions: [(Self, String)] = [
        (.microphoneOn, "microphoneOn"),
        (.cameraOn, "cameraOn"),
        (.sleeping, "sleeping"),
        (.locked, "locked"),
    ]

    public var description: String {
        let result: [String] = Self.descriptions.filter { contains($0.0) }.map { $0.1 }
        return "\(type(of:self)): (rawValue: \(self.rawValue)) [\(result.joined(separator:", "))]"
    }
}

public extension ApplicationState {
    
//    init() {
//        
//    }
    
    
}
