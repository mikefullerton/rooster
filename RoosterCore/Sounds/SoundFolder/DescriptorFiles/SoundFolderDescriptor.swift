//
//  SoundFolderDescriptor.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/1/21.
//

import Foundation

public struct SoundFolderDescriptor: Codable, SoundFolderItemDescriptor {
    
    public typealias FileType = SoundFolderDescriptor
   
    public var metadata: SoundFolderItemMetaData
    
    public var description: String {
        return """
        type(of:self): \
        metaData: \(self.metadata)
        """
    }
   
    public init(withID id: String, displayName: String) {
        self.metadata = SoundFolderItemMetaData(withID: id, displayName: displayName)
    }
    
   
    public static func metadataFileURL(fromURL url: URL) -> URL {
        return url.appendingPathComponent("\(url.lastPathComponent).roosterFolder")
    }
}


