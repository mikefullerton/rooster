//
//  Dictionary+Utiities.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation

public extension Dictionary {
    var sortedKeys: [Key] {
        if let keys:[String] = Array(self.keys) as? [String] {
            let sortedKeys = keys.sorted {
                $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending
            }
            
            if let finalKeys = sortedKeys as? [Key] {
                return finalKeys
            }
        }
        
        return Array(self.keys).sorted { (lhs, rhs) -> Bool in
            return lhs == rhs
        }
    }
    
    static func replaceAll(inDictionary dest: inout [Key: Value],
                           withContentsOf source: [Key: Value]) {
        dest.removeAll()
        for (key, value) in source {
            dest[key] = value
        }
    }
}
