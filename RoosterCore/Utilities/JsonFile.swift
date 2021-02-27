//
//  JsonFile.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/25/21.
//

import Foundation
import Cocoa

public struct JsonFile<T: Codable> {
    
    public let url: URL
    
    public init(withURL url: URL) {
        self.url = url
    }
    
    public func read() throws -> T {
        let data = try Data(contentsOf: self.url)
        let decoder = JSONDecoder()
        let contents = try decoder.decode(T.self, from: data)
        return contents
    }
    
    public func write(_ item: T) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [ .prettyPrinted, .sortedKeys ]

        let data = try encoder.encode(item)

        try data.write(to: self.url)
    }

    public func delete() throws {
        try FileManager.default.removeItem(at: self.url)
    }
    
    public var exists: Bool {
        return FileManager.default.fileExists(atPath: self.url.path)
    }
}
