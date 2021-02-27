//
//  PairStringFormatter.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/8/20.
//

import Foundation

public struct StringFormatter  {
    
    private var tokens: [String]
    
    public init(withTitle title: String) {
        self.tokens = []
        self.tokens.append(title)
    }
    
    public mutating func append(_ string: String) {
        self.tokens.append(string)
    }
    
    public mutating func append(_ key: String, _ value: Any?) {
        let valueString = value != nil ? String(describing: value!) : "nil"
        self.tokens.append("\(key): \(valueString)")
    }
    
    public mutating func append(_ key: String, _ value: String?) {
        self.tokens.append("\(key): \(value ?? "nil" )")
    }
    
    public var string: String {
        return self.tokens.joined(separator: ", ")
    }
    
    public var description : String {
        return self.string
    }
}
