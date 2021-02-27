//
//  SoundFolderItem.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/11/21.
//

import Foundation

public protocol SoundFolderItem: AnyObject, CustomStringConvertible {
    var parent: SoundFolder? { get }
    var displayName: String { get }
    var id: String { get }
    var relativePath: URL { get }
    var absolutePath: URL? { get }
    func setParent(_ soundFolder: SoundFolder?)
}

extension SoundFolderItem {
    
    public var parents: [SoundFolder] {
        var parents:[SoundFolder] = []
        
        var walker = self.parent
        
        while (walker != nil) {
            parents.append(walker!)
            walker = walker!.parent
        }
        
        return parents.reversed()
    }
    
    public var pathComponents: [SoundFolderItem] {
        return self.parents + [self]
    }
    
    public var displayNameWithParents: String {
        var names:[String] = []
        
        names.append(self.displayName)
        
        var walker = self.parent
        
        while (walker != nil) {
            names.append(walker!.displayName)
            walker = walker!.parent
        }
        
        return names.reversed().joined(separator: "/")
    }
    
    public var searchableStrings: [String] {
        let list = self.parents.map { $0.displayName } + [ self.displayName ]
        return list
    }
    
    public func searchMatches(_ searchString: String) -> Bool {
        for string in self.searchableStrings {
            if string.localizedCaseInsensitiveContains(searchString) {
                return true
            }
        }
        
        return false
    }
    
    public func setParent(_ soundFolder: SoundFolder?) {
        
    }
    
    public var relativePathFromRootFolder: URL {
        if let parent = self.parent {
            return parent.relativePathFromRootFolder.appendingPathComponent(self.relativePath.lastPathComponent)
        }
        
        return URL(withRelativePath: self.relativePath.lastPathComponent)
    }

    public var rootFolder: SoundFolder? {
        if let parent = self.parent {
            return parent.rootFolder
        }
        
        return self as? SoundFolder
    }
}

