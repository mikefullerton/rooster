//
//  JsonFile.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/25/21.
//

import Foundation
import Cocoa

struct JsonFile<T: Codable> {
    
    let url: URL
    
    init(withURL url: URL) {
        self.url = url
    }
    
    func read() throws -> T {
        let data = try Data(contentsOf: self.url)
        let decoder = JSONDecoder()
        let contents = try decoder.decode(T.self, from: data)
        return contents
    }
    
    func write(_ item: T) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [ .prettyPrinted, .sortedKeys ]

        let data = try encoder.encode(item)

        try data.write(to: self.url)
    }

    func delete() throws {
        try FileManager.default.removeItem(at: self.url)
    }
    
    var exists: Bool {
        return FileManager.default.fileExists(atPath: self.url.path)
    }
}
