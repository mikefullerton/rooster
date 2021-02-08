//
//  JSONFile.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/7/21.
//

import Foundation

extension Dictionary {
    func toJSON() throws -> String?  {
        let jsonData = try JSONSerialization.data(withJSONObject: self,
                                                  options: [.prettyPrinted, .sortedKeys])
        
        return String(bytes: jsonData, encoding: String.Encoding.utf8)
    }
    
    func writeJSON(toURL url: URL) throws {
        if let jsonString = try self.toJSON() {
            try jsonString.write(to: url, atomically: true, encoding: .utf8)
        }
    }
    
    static func readJSON(fromURL url: URL) throws -> [AnyHashable: Any]? {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        
        let jsonData = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: jsonData as Data,
                                                    options: JSONSerialization.ReadingOptions.mutableContainers) as! [AnyHashable: Any]
        
        return json
    }
}
