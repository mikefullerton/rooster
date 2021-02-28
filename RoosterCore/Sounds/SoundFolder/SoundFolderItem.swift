//
//  SoundFolderItem.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/11/21.
//

import Foundation

//public protocol SoundFolderItemUtils {
//    // these all have default implementations
//    var displayNameWithParentsExcludingRoot: String { get }
//    var displayNameWithParents: String { get }
//    var pathComponents: [SoundFolderItem] { get }
//    var parents: [SoundFolder] { get }
//    var relativePathFromRootFolder: URL { get }
//    var rootFolder: SoundFolder? { get }
//}
//
//public protocol SoundFolderItem: AnyObject, CustomStringConvertible, SoundFolderItemUtils {
//    var parent: SoundFolder? { get }
//    var displayName: String { get }
//    var id: String { get }
//    var relativePath: URL { get }
//    var absolutePath: URL? { get }
//    func setParent(_ soundFolder: SoundFolder?)
//
//    static func metadataFileURL(fromURL url: URL) -> URL
//
//}

public class SoundFolderItem: Identifiable, Loggable, CustomStringConvertible {
  
    public typealias ID = String
    
    public var displayName: String
    public var id: String
//    public var relativePath: URL
//    public var absolutePath: URL?
    
    public init(withID id: String,
                displayName: String) {
        
        self.id = id
        self.displayName = displayName
        
        self.relativePath = URL.empty
        self.absolutePath = nil
        
        self.parent = nil
    }
    
    public var description: String {
        return ""
    }
    
//    private(set)
    public var absolutePath: URL? {
        didSet {
            self.logger.log("New url (absolute): \(self.absolutePath?.path ?? "nil"), for folder: \(self.description)")
            self.didSetAbsolutePath()
        }
    }
    
//    private(set)
    public var relativePath: URL {
        didSet {
            self.logger.log("New url (relative): \(self.relativePath.path), old: \(oldValue)")
            self.didSetRelativePath()
        }
    }
    
    //fileprivate(set) 
    public weak var parent: SoundFolder? {
        didSet {
            self.didSetParent()
        }
    }
    
    func didSetParent() {
        self.updateRelativePath()
    }
    
    func didSetAbsolutePath() {
        
    }
    
    func didSetRelativePath() {
        
    }
    
    func updateRelativePath() {
        
    }
    
    public func setParent(_ soundFolder: SoundFolder?) {
        self.parent = soundFolder
    }
 
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

    public var displayNameWithParentsExcludingRoot: String {
        var names:[String] = []
        
        names.append(self.displayName)
        
        var walker = self.parent
        
        while (walker != nil) {
            if walker!.parent != nil {
                names.append(walker!.displayName)
            }
            walker = walker!.parent
        }
        
        return names.reversed().joined(separator: " / ")
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

