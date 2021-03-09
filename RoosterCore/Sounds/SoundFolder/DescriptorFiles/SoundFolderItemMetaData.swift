//
//  SoundFolderItemMetaData.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/1/21.
//

import Foundation

public struct SoundFolderItemMetaData: Identifiable, CustomStringConvertible {
    public typealias ID = String

    public var id: String
    public var author: String
    public var link: URL
    public var notes: String
    public var categories: [String]
    public var displayName: String

    public static let `default` = SoundFolderItemMetaData()

    public init(withID id: String, displayName: String) {
        self.id = id
        self.displayName = displayName
        self.author = ""
        self.link = URL.empty
        self.notes = ""
        self.categories = []
    }

    public init() {
        self.init(withID: "", displayName: "")
    }

    public var description: String {
        """
        \(type(of: self)): \
        id: \(self.id), '
        displayName: \(self.displayName)
        """
    }
}

extension SoundFolderItemMetaData: Codable {
    private enum CodingKeys: String, CodingKey {
        case id
        case author
        case link
        case notes
        case categories
        case displayName
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decodeIfPresent(String.self, forKey: .id) ?? Self.default.id
        self.author = try values.decodeIfPresent(String.self, forKey: .author) ?? Self.default.author
        self.link = try values.decodeIfPresent(URL.self, forKey: .link) ?? Self.default.link
        self.notes = try values.decodeIfPresent(String.self, forKey: .notes) ?? Self.default.notes
        self.categories = try values.decodeIfPresent([String].self, forKey: .categories) ?? Self.default.categories
        self.displayName = try values.decodeIfPresent(String.self, forKey: .displayName) ?? Self.default.displayName
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.author, forKey: .author)
        try container.encode(self.link, forKey: .link)
        try container.encode(self.notes, forKey: .notes)
        try container.encode(self.categories, forKey: .categories)
        try container.encode(self.displayName, forKey: .displayName)
    }
}
