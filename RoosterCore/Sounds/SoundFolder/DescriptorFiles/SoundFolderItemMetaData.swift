//
//  SoundFolderItemMetaData.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/1/21.
//

import Foundation

public struct SoundFolderItemMetaData : Codable, Identifiable, CustomStringConvertible {
    
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
    
    public var description: String {
        return """
        type(of:self): \
        id: \(self.id), '
        displayName: \(self.displayName)
        """
    }
}
