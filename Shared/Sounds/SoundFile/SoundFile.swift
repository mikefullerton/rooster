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
    var url: URL
    var displayName: String
    var randomizer: RandomizationDescriptor?
    
    weak var parent: SoundFolder?
    
    convenience init() {
        self.init(withID: "",
                  url: URL.emptyRoosterURL,
                  displayName: "",
                  randomizer: nil)
    }

    init(withID id: String,
         url: URL,
         displayName: String,
         randomizer: RandomizationDescriptor? = nil) {
        self.url = url
        self.id = id
        self.displayName = displayName
        self.randomizer = randomizer
    }
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case url = "url"
        case displayName = "displayName"
        case randomizer = "randomizer"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try self.id = values.decode(String.self, forKey: .id)
        try self.displayName = values.decode(String.self, forKey: .displayName)
        try self.url = values.decode(URL.self, forKey: .url)
        try self.randomizer = values.decode(RandomizationDescriptor.self, forKey: .randomizer)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.displayName, forKey: .displayName)
        try container.encode(self.url, forKey: .url)
        try container.encode(self.randomizer, forKey: .randomizer)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return SoundFile(withID: self.id, url: self.url, displayName: self.displayName, randomizer: self.randomizer)
    }

    var description: String {
        return "\(type(of:self)): \(self.id), displayName: \(self.displayName), url: \(self.url.absoluteString), randomizingBehavior: \(self.randomizer?.description ?? "none"))"
    }

    static func == (lhs: SoundFile, rhs: SoundFile) -> Bool {
        return lhs.id == rhs.id &&
            lhs.displayName == rhs.displayName &&
            lhs.url == rhs.url &&
            lhs.randomizer == rhs.randomizer
    }
}
