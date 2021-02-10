//
//  SoundFolder+Extensions.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/11/21.
//

import Foundation

extension SoundFolder: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        return SoundFolder(withID: self.id, url: self.url, displayName: self.displayName, sounds: self.sounds, subFolders: self.subFolders)
    }
}

extension SoundFolder: CustomStringConvertible {
    var description: String {
        return "\(type(of:self)): id: \(self.id), displayName: \(self.displayName), url: \(String(describing:self.url)), soundCount: \(self.sounds.count), subFoldersCount:\(self.subFolders.count), parent: \(self.parent?.description ?? "nil")"
    }
}

extension SoundFolder: Equatable {
    static func == (lhs: SoundFolder, rhs: SoundFolder) -> Bool {
        return lhs.id == rhs.id &&
            lhs.url == rhs.url &&
            lhs.displayName == rhs.displayName &&
            lhs.sounds == rhs.sounds &&
            lhs.subFolders == rhs.subFolders
    }
}

extension SoundFolder: CustomDebugStringConvertible {
    
    var debugDescription: String {
        
        var allItems: [String] = []
        
        self.visitEach { item in
            allItems.append(item.description.prepend(with: " ", count: item.parents.count * 4))
        }
        
        let allItemsString = allItems.joined(separator: "\n")
        
        return "\(self.description):\n\(allItemsString)"
    }
}
