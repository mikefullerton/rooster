//
//  SoundFile.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/3/21.
//

import Foundation

class SoundFile: Identifiable, SoundFolderItem, Codable, CustomStringConvertible, Equatable, NSCopying {
    typealias ID = String
    
    let id: String
    let fileName: String
    var displayName: String

    private(set) var url: URL?
    
    weak var parent: SoundFolder? {
        didSet {
            if let parent = self.parent {
                self.url = parent.url.appendingPathComponent(self.fileName)
            } else {
                self.url = nil
            }
        }
    }
  
    convenience init() {
        self.init(withID: "",
                  fileName: "",
                  displayName: "")
    }

    init(withID id: String,
         fileName: String,
         displayName: String) {
        self.fileName = fileName
        self.id = id
        self.displayName = displayName
        self.url = nil
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case fileName = "fileName"
        case displayName = "displayName"
        case url = "url"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try self.id = values.decode(String.self, forKey: .id)
        try self.displayName = values.decode(String.self, forKey: .displayName)
        try self.fileName = values.decode(String.self, forKey: .fileName)
        try self.url = URL(string: values.decode(String.self, forKey: .url))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.displayName, forKey: .displayName)
        try container.encode(self.fileName, forKey: .fileName)
        try container.encode(self.url?.absoluteString, forKey: .url)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return SoundFile(withID: self.id, fileName: self.fileName, displayName: self.displayName)
    }

    var description: String {
        return "\(type(of:self)): \(self.id), displayName: \(self.displayName), fileName: \(self.fileName), url: \(String(describing:self.url)))"
    }

    static func == (lhs: SoundFile, rhs: SoundFile) -> Bool {
        return  lhs.id == rhs.id &&
                lhs.displayName == rhs.displayName &&
                lhs.fileName == rhs.fileName
    }
}
