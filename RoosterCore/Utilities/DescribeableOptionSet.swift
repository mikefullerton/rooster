//
//  DescribeableOptionSet.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/16/21.
//

import Foundation


public protocol DescribeableOptionSet: OptionSet, CustomStringConvertible, AdditiveArithmetic, Codable {
    
    static var descriptions: [(Self.Element, String)] { get }
}

extension DescribeableOptionSet {
    public var description: String {
        let result: [String] = Self.descriptions.filter {
            self.contains($0.0)
        }.map {
            ".\($0.1)"
        }
        
        return "[\(result.joined(separator:", "))] (\(rawValue)) "
    }
    
    public static func + (lhs: Self, rhs: Self) -> Self {
        var state = lhs
        state.insert(rhs as! Self.Element)
        return state
    }

    public static func += (lhs: inout Self, rhs: Self) {
        lhs.insert(rhs as! Self.Element)
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        var state = lhs
        state.remove(rhs as! Self.Element)
        return state
    }

    public static func -= (lhs: inout Self, rhs: Self) {
        lhs.remove(rhs as! Self.Element)
    }
    
//    public static func == (lhs: Self, rhs: Self) -> Bool {
//        return (lhs as! Self.Element).rawValue == (rhs as! Self.Element).rawValue
//    }

//    public static func == (lhs: Self, rhs: Self) -> Bool {
//        return (lhs as? Self.Element).rawValue == (rhs as? Self.Element).rawValue
//    }
//

}


