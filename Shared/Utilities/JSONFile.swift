//
//  JSONFile.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/7/21.
//

import Foundation

extension Dictionary {
    func toJSON() throws -> String?  {
        let jsonData = try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted, .sortedKeys])
        return String(bytes: jsonData, encoding: String.Encoding.utf8)
    }
    
    func write(toJsonFileURL url: URL) throws {
        if let jsonString = try self.toJSON() {
            try jsonString.write(to: url, atomically: true, encoding: .utf8)
        }
    }
}
