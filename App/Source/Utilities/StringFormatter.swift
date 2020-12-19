//
//  PairStringFormatter.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/8/20.
//

import Foundation

struct StringFormatter  {
    
    private var tokens: [String]
    
    init(withTitle title: String) {
        self.tokens = []
        self.tokens.append(title)
    }
    
    mutating func append(_ string: String) {
        self.tokens.append(string)
    }
    
    mutating func append(_ key: String, _ value: Any?) {
        let valueString = value != nil ? String(describing: value!) : "nil"
        self.tokens.append("\(key): \(valueString)")
    }
    
    mutating func append(_ key: String, _ value: String?) {
        self.tokens.append("\(key): \(value ?? "nil" )")
    }
    
    var string: String {
        return self.tokens.joined(separator: ", ")
    }
    
    var description : String {
        return self.string
    }
}
