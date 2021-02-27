//
//  SoundFile.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/3/21.
//

import Foundation

public class SoundFile: Identifiable, SoundFolderItem, Codable, CustomStringConvertible, Equatable, NSCopying, Loggable {
    
    public typealias ID = String
    
    public let id: String
    public let fileName: String
    public var displayName: String
    
    private(set) public var relativePath: URL {
        didSet {
            print("New SoundFile relative path: \(self.relativePath.path)")
        }
    }
    
    public var absolutePath: URL? {
        if let rootFolderPath = self.rootFolder?.absolutePath {
            let outPath = rootFolderPath.deletingLastPathComponent().appendingPathComponent(self.relativePath.path)
            self.logger.log("sound file path: \(outPath)")
            return outPath
        }
        
        return nil
    }
    
    public weak var parent: SoundFolder? {
        didSet {
            self.updateRelativePath()
        }
    }
  
    public convenience init() {
        self.init(withID: "",
                  fileName: "",
                  displayName: "")
    }

    public init(withID id: String,
                fileName: String,
                displayName: String) {
        self.fileName = fileName
        self.id = id
        self.displayName = displayName
        self.relativePath = URL(withRelativePath: fileName)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case fileName = "fileName"
        case displayName = "displayName"
        case relativePath = "relativePath"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try self.id = values.decode(String.self, forKey: .id)
        try self.displayName = values.decode(String.self, forKey: .displayName)
        try self.fileName = values.decode(String.self, forKey: .fileName)
        try self.relativePath = values.decode(URL.self, forKey: .relativePath)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.displayName, forKey: .displayName)
        try container.encode(self.fileName, forKey: .fileName)
        try container.encode(self.relativePath.path, forKey: .relativePath)
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        return SoundFile(withID: self.id, fileName: self.fileName, displayName: self.displayName)
    }

    public var description: String {
        return """
        \(type(of:self)): \
        id: \(self.id), \
        displayName: \(self.displayName), \
        fileName: \(self.fileName), \
        relativePath: \(self.relativePath.path), \
        absolutePath: \(self.absolutePath?.path ?? "nil")"
        """
    }

    public static func == (lhs: SoundFile, rhs: SoundFile) -> Bool {
        return  lhs.id == rhs.id &&
                lhs.displayName == rhs.displayName &&
                lhs.fileName == rhs.fileName
    }
    
    public func updateRelativePath() {
        self.relativePath = self.relativePathFromRootFolder
        
        self.logger.log("New url for \(self.description)")
    }
}

extension SoundFile {
    public convenience init(withDescriptor descriptor: SoundFolderItemDescriptor, atPath url: URL) {
        self.init(withID: descriptor.id,
                  fileName:url.lastPathComponent,
                  displayName: descriptor.displayName)
    }
    
    public static func descriptorFileURL(forURL url: URL) -> URL {
        let name = url.deletingPathExtension().lastPathComponent
        return url.deletingLastPathComponent().appendingPathComponent("\(name).roosterSound")
    }
}
