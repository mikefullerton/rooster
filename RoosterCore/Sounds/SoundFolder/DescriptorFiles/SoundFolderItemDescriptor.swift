//
//  File.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/25/21.
//

import Foundation


public protocol SoundFolderItemDescriptor : Loggable, CustomStringConvertible {
    
    associatedtype FileType: Codable, SoundFolderItemDescriptor
    
    var metadata: SoundFolderItemMetaData { get set }
    
    init(withID id: String, displayName: String)

    static func metadataFileURL(fromURL url: URL) -> URL
}
//static func urlFromAssociatedItem(atURL associatedItemURL: URL) -> URL

extension SoundFolderItemDescriptor {

    public static func read(fromURL url: URL) throws -> FileType {
        let fileURL = FileType.metadataFileURL(fromURL: url)
        let jsonFile = JsonFile<FileType>(withURL: fileURL)
        return try jsonFile.read()
    }
}

