//
//  File.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/25/21.
//

import Foundation

public struct SoundFolderItemDescriptor : Codable, Identifiable, Loggable, CustomStringConvertible {
    
    public typealias ID = String
    
    public var id: String
    public var author: String
    public var link: URL
    public var notes: String
    public var categories: [String]
    public var displayName: String
    
    public init(withID id: String, displayName: String) {
        self.id = id
        self.displayName = displayName
        self.author = ""
        self.link = URL.empty
        self.notes = ""
        self.categories = []
    }
    
    public static func read(fromURL url: URL) throws -> SoundFolderItemDescriptor {
        let jsonFile = JsonFile<SoundFolderItemDescriptor>(withURL: url)
        return try jsonFile.read()
    }
    
    public func write(toURL url: URL) throws {
        let jsonFile = JsonFile<SoundFolderItemDescriptor>(withURL: url)
        try jsonFile.write(self)
    }
    
    public func exists(atURL url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    private static func cleanupName(_ url: URL?) -> String {
        if let theURL = url {
            
            var cleanedName = theURL.deletingPathExtension().lastPathComponent
            
            [ "-", "_" ].forEach { cleanedName = cleanedName.replacingOccurrences(of: $0, with: " ")}

            return cleanedName
        }
        
        return ""
    }
    
    public var description: String {
        return """
        type(of:self): \
        id: \(self.id), '
        displayName: \(self.displayName)
        """
    }

    public static func readOrCreateDescriptor(atURL url: URL,
                                       withID optionalIDOrNil: String? = nil) throws -> SoundFolderItemDescriptor {
        
        let jsonFile = JsonFile<SoundFolderItemDescriptor>(withURL: url)
        
        if jsonFile.exists {
            
            
            var descriptor = try jsonFile.read()
            
            if let optionalID = optionalIDOrNil {
                
                if descriptor.id == optionalID {
                    return descriptor
                }
            
                descriptor.id = optionalID
                try descriptor.write(toURL: url)
                
                return descriptor
            }

            self.logger.log("Loaded descriptor: \(descriptor.description) from path: \(url.path)")

            return descriptor
        }
        
        let newID = optionalIDOrNil == nil ? String.guid : optionalIDOrNil!
        
        let newFile = SoundFolderItemDescriptor(withID: newID, displayName: Self.cleanupName(url))
        
        self.logger.log("Creating desc \(newFile.description) at: \(url.path)")

        try jsonFile.write(newFile)
        
        return newFile
    }

}
