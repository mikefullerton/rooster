//
//  SoundSetRandomizer.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/8/21.
//

import Foundation

public struct PlayListRandomizer: Loggable, Codable {
    
    public enum Frequency : Int, Codable {
        case almostNever
        case rare
        case seldom
        case low
        case normal
        case high
        case frequent
    }
   
    public enum Behavior: Int, Codable {
        case never
        case always
    }
    
    public var behavior: Behavior
    
    // ignored if behavior is .never
    public var frequency: Frequency
    public var minSounds: Int
    public var maxSounds: Int
    
    public var alwaysFirst: Bool
    
    private init() {
        self.frequency = .normal
        self.behavior = .never
        self.minSounds = 0
        self.maxSounds = 0
        self.alwaysFirst = false
    }
    
    public init(withBehavior behavior: Behavior,
                minSounds: Int = 0,
                maxSounds: Int = 0) {
       
        self.behavior = behavior
        self.frequency = .normal
        self.minSounds = minSounds
        self.maxSounds = maxSounds
        self.alwaysFirst = false
    }
    
    public init(withBehavior behavior: Behavior,
                frequency: Frequency,
                alwaysFirst: Bool,
                minSounds: Int,
                maxSounds: Int) {
       
        self.behavior = behavior
        self.frequency = .normal
        self.minSounds = minSounds
        self.maxSounds = maxSounds
        self.alwaysFirst = alwaysFirst
    }
    
    public init(withBehavior behavior: Behavior,
                frequency: Frequency,
                alwaysFirst: Bool = false)  {
    
        self.behavior = behavior
        self.frequency = frequency
        self.minSounds = 0
        self.maxSounds = 0
        self.alwaysFirst = alwaysFirst
    }
    
    public static var never = PlayListRandomizer()
    
    public static var always = PlayListRandomizer(withBehavior: .always)
}

extension PlayListRandomizer: CustomStringConvertible {
    
    public var description: String {
        return "\(type(of:self)): frequency: \(self.frequency.description), minSounds: \(self.minSounds), maxSounds: \(self.maxSounds), always first: \(self.alwaysFirst)"
    }
}

extension PlayListRandomizer: Equatable {
    public static func == (lhs: PlayListRandomizer, rhs: PlayListRandomizer) -> Bool {
        return lhs.behavior == rhs.behavior &&
            lhs.frequency == rhs.frequency &&
            lhs.minSounds == rhs.minSounds &&
            lhs.maxSounds == rhs.maxSounds &&
            lhs.alwaysFirst == rhs.alwaysFirst
    }
}

extension PlayListRandomizer.Frequency: CustomStringConvertible, Comparable, Equatable {
    public var description: String {
        switch self {
        case .almostNever:
            return "almostNever"
        
        case .rare:
            return "rare"
        
        case .seldom:
            return "seldom"
        
        case .low:
            return "low"
            
        case .normal:
            return "normal"
            
        case .high:
            return "high"
            
        case .frequent:
            return "frequent"
        }
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    public static func <= (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue <= rhs.rawValue
    }

    public static func >= (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue >= rhs.rawValue
    }

    public static func > (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    public static var random: PlayListRandomizer.Frequency {
        return PlayListRandomizer.Frequency(rawValue: Int.random(in: 0...PlayListRandomizer.Frequency.frequent.rawValue))!
    }
}






