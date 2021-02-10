//
//  SoundSetRandomizer.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/8/21.
//

import Foundation

struct RandomizationDescriptor: Loggable, Codable {
    
    enum Frequency : Int, Codable {
        case almostNever
        case rare
        case seldom
        case low
        case normal
        case high
        case frequent
    }
   
    enum Behavior: Int, Codable {
        case never
        case always
    }
    
    var behavior: Behavior
    
    // ignored if behavior is .never
    var frequency: Frequency
    var minSounds: Int
    var maxSounds: Int
    
    var alwaysFirst: Bool
    
    private init() {
        self.frequency = .normal
        self.behavior = .never
        self.minSounds = 0
        self.maxSounds = 0
        self.alwaysFirst = false
    }
    
    init(withBehavior behavior: Behavior,
         minSounds: Int = 0,
         maxSounds: Int = 0) {
       
        self.behavior = behavior
        self.frequency = .normal
        self.minSounds = minSounds
        self.maxSounds = maxSounds
        self.alwaysFirst = false
    }
    
    init(withBehavior behavior: Behavior,
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
    
    init(withBehavior behavior: Behavior,
         frequency: Frequency,
         alwaysFirst: Bool = false)  {
    
        self.behavior = behavior
        self.frequency = frequency
        self.minSounds = 0
        self.maxSounds = 0
        self.alwaysFirst = alwaysFirst
    }
    
    static var none = RandomizationDescriptor()
    
    static var always = RandomizationDescriptor(withBehavior: .always)
}

extension RandomizationDescriptor: CustomStringConvertible {
    
    var description: String {
        return "\(type(of:self)): frequency: \(self.frequency.description), minSounds: \(self.minSounds), maxSounds: \(self.maxSounds), always first: \(self.alwaysFirst)"
    }
}

extension RandomizationDescriptor: Equatable {
    static func == (lhs: RandomizationDescriptor, rhs: RandomizationDescriptor) -> Bool {
        return lhs.behavior == rhs.behavior &&
            lhs.frequency == rhs.frequency &&
            lhs.minSounds == rhs.minSounds &&
            lhs.maxSounds == rhs.maxSounds &&
            lhs.alwaysFirst == rhs.alwaysFirst
    }
}

extension RandomizationDescriptor.Frequency: CustomStringConvertible, Comparable, Equatable {
    var description: String {
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

    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    static func <= (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue <= rhs.rawValue
    }

    static func >= (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue >= rhs.rawValue
    }

    static func > (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    static var random: RandomizationDescriptor.Frequency {
        return RandomizationDescriptor.Frequency(rawValue: Int.random(in: 0...RandomizationDescriptor.Frequency.frequent.rawValue))!
    }
}






