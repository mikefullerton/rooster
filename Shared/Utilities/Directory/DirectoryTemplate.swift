//
//  DirectoryTemplate.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/7/21.
//

import Foundation

class DirectoryItem: Loggable, Equatable, Identifiable {
    
    let url: URL
    let id: String
    
    weak private(set) var parent: DirectoryItem?

    init(withID id: String,
         url: URL,
         parent: DirectoryItem?) {
        self.id = id
        self.url = url
        self.parent = parent
    }
    
    var isDirectory: Bool {
        return false
    }
    
    var name: String {
        return self.url.lastPathComponent
    }
    
    var relativePath: String {
        var names:[String] = []
        
        names.append(self.name)
        
        var walker = self.parent
        
        while (walker != nil) {
            names.append(walker!.name)
            walker = walker!.parent
        }
        
        return names.reversed().joined(separator: "/")
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    static func == (lhs: DirectoryItem, rhs: DirectoryItem) -> Bool {
        return  lhs.url == rhs.url &&
                lhs.id == rhs.id
    }
   
    var description: String {
        return "\(type(of:self)): id: \(self.id), url:\(self.url.path)"
    }
}

class DirectoryTemplate<DIR_ITEM, FILE_ITEM> : DirectoryItem {
    
    typealias Directory = DirectoryTemplate<DIR_ITEM, FILE_ITEM>
//    typealias File = DirectoryTemplate<DIR_ITEM, FILE_ITEM>.File

    private(set) var directories:[Directory]
    private(set) var files: [File]
    private(set) var contents: [DirectoryItem]
    
    private var data: Any? = nil
    
    convenience init(withURL url: URL,
                     parent: Directory? = nil) throws {
     
        try self.init(withID: url.absoluteString,
                      url:url, parent: parent)
    }

    init(withID id: String,
         url: URL,
         parent: Directory? = nil) throws {
        
        self.directories = []
        self.files = []
        self.contents = []

        super.init(withID: id,
                   url:url,
                   parent:parent)
        
        try self.updateContents()
    }
    
    func createDirectory(withURL url: URL,
                         parent: Directory?) throws -> Directory {

        return try Directory(withID: url.absoluteString,
                                           url: url,
                                           parent: parent)
    }

    func createFile(withURL url: URL, parent: Directory) -> File {
        return File(withID: url.absoluteString,
                                            url: url,
                                            parent: parent)
    }

    override var isDirectory: Bool {
        return true
    }

    func updateContents() throws {
        
        var files:[File] = []
        var directories:[Directory] = []
        var contents:[DirectoryItem] = []

        let contentPaths = try FileManager.default.contentsOfDirectory(atPath: url.path)
        for itemPath in contentPaths {
            if itemPath.hasPrefix(".") {
                continue
            }
            
            let itemURL = url.appendingPathComponent(itemPath)
            
            var isDir : ObjCBool = false
            if FileManager.default.fileExists(atPath: itemURL.path, isDirectory: &isDir) {
                if isDir.boolValue {
                    let item = try self.createDirectory(withURL: itemURL, parent: self)
                    contents.append(item)
                    directories.append(item)
                } else {
                    let item = self.createFile(withURL: itemURL, parent: self)
                    contents.append(item)
                    files.append(item)
                }
            }
        }
        
        self.contents = contents.sorted(by: { lhs, rhs in
            lhs.name.localizedCaseInsensitiveCompare(rhs.name) == ComparisonResult.orderedAscending
        })
        
        self.files = files.sorted { lhs, rhs in
            lhs.name.localizedCaseInsensitiveCompare(rhs.name) == ComparisonResult.orderedAscending
        }

        self.directories = directories.sorted { lhs, rhs in
            lhs.name.localizedCaseInsensitiveCompare(rhs.name) == ComparisonResult.orderedAscending
        }
    }
    
    typealias Visitor = (_ item: DirectoryItem, _ depth: Int) -> Void
    
    private func visitEach(depth: Int,
                           visitor: Visitor) {
        
        self.contents.forEach { (item) in
            visitor(item, depth)
            if let dir = item as? Directory {
                dir.visitEach(depth: depth + 1, visitor:visitor)
            }
        }
    }
    
    func visitEach(_ visitor: Visitor) {
        visitor(self, 0)
        self.visitEach(depth: 1, visitor: visitor)
    }
    
    override var description: String {
        
        var allItems: [String] = []
        
        self.visitEach() { item, depth in
            allItems.append(item.name.prepend(with: " ", count: depth * 4))
        }
        
        let allItemsString = allItems.joined(separator: "\n")
        
        return "\(type(of:self)): \(self.url.path):\n\(allItemsString)"
    }
    
    static func == (lhs: Directory, rhs: Directory) -> Bool {
        return  lhs.url == rhs.url &&
                lhs.directories == rhs.directories &&
                lhs.files == rhs.files
    }
    
    class File : DirectoryItem {
        init(withURL url: URL,
             parent: Directory?) {
            super.init(withID: url.absoluteString, url: url, parent: parent)
        }
        
        init(withID id: String,
             url: URL,
             parent: Directory?) {
            super.init(withID: id, url: url, parent: parent)
        }

        static func == (lhs: File, rhs: File) -> Bool {
            return  lhs.url == rhs.url
        }
    }
}

class EmptyContents {
    
}

typealias Directory = DirectoryTemplate<EmptyContents, EmptyContents>

