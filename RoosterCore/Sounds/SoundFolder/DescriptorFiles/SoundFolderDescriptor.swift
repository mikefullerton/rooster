//
//  SoundFolderDescriptor.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/1/21.
//

import Foundation

public struct SoundFolderDescriptor: SoundFolderItemDescriptor {
    public typealias FileType = SoundFolderDescriptor

    public var metadata: SoundFolderItemMetaData

    public static let `default` = SoundFolderDescriptor()

    public var description: String {
        """
        \(type(of: self)): \
        metaData: \(self.metadata)
        """
    }

    public init(withID id: String, displayName: String) {
        self.metadata = SoundFolderItemMetaData(withID: id, displayName: displayName)
    }

    public init() {
        self.init(withID: "", displayName: "")
    }

    public static func metadataFileURL(fromURL url: URL) -> URL {
        url.appendingPathComponent("\(url.lastPathComponent).roosterFolder")
    }
}

extension SoundFolderDescriptor: Codable {
    private enum CodingKeys: String, CodingKey {
        case metadata
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.metadata = try values.decodeIfPresent(SoundFolderItemMetaData.self, forKey: .metadata) ?? Self.default.metadata
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.metadata, forKey: .metadata)
    }
}
