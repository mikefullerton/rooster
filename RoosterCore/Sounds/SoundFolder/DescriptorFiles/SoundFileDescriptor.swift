//
//  SoundFileDescriptor.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/1/21.
//

import Foundation

public struct SoundFileDescriptor: Codable, SoundFolderItemDescriptor {
    public typealias FileType = SoundFileDescriptor

    public var metadata: SoundFolderItemMetaData

    public var description: String {
        """
        \(type(of: self)): \
        metaData: \(self.metadata)
        """
    }

    public init(withID id: String, displayName: String) {
        self.metadata = SoundFolderItemMetaData(withID: id, displayName: displayName)
    }

    public static func metadataFileURL(fromURL url: URL) -> URL {
        let name = url.deletingPathExtension().lastPathComponent
        return url.deletingLastPathComponent().appendingPathComponent("\(name).roosterSound")
    }
}
