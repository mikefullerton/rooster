//
//  SoundFolderItem.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/11/21.
//

import Foundation

protocol SoundFolderItem: AnyObject, CustomStringConvertible {
    var parent: SoundFolder? { get }
    var displayName: String { get }
    var id: String { get }
    var url: URL { get }
    func setParent(_ soundFolder: SoundFolder?)
}

extension SoundFolderItem {
    
    var parents: [SoundFolder] {
        var parents:[SoundFolder] = []
        
        var walker = self.parent
        
        while (walker != nil) {
            parents.append(walker!)
            walker = walker!.parent
        }
        
        return parents.reversed()
    }
    
    var pathComponents: [SoundFolderItem] {
        return self.parents + [self]
    }
    
    var displayNameWithParents: String {
        var names:[String] = []
        
        names.append(self.displayName)
        
        var walker = self.parent
        
        while (walker != nil) {
            names.append(walker!.displayName)
            walker = walker!.parent
        }
        
        return names.reversed().joined(separator: "/")
    }
    
    var searchableStrings: [String] {
        let list = self.parents.map { $0.displayName } + [ self.displayName ]
        return list
    }
    
    func searchMatches(_ searchString: String) -> Bool {
        for string in self.searchableStrings {
            if string.localizedCaseInsensitiveContains(searchString) {
                return true
            }
        }
        
        return false
    }
    
    func setParent(_ soundFolder: SoundFolder?) {
        
    }
}

