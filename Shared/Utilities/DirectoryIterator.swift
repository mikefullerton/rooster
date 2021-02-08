//
//  DirectoryTemplate.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/7/21.
//

import Foundation

protocol DirectoryIteratorItem: AnyObject {
    var isDirectory: Bool { get }
    var url: URL? { get }
    var name: String { get }
    var parent: DirectoryIterator? { get }
}

extension DirectoryIteratorItem {
    var isDirectory:Bool {
        return false
    }
    
    var name: String {
        return self.url?.lastPathComponent ?? ""
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
}

class DirectoryIterator: DirectoryIteratorItem, Equatable, CustomStringConvertible {
    
    private(set) var directories:[DirectoryIterator]
    private(set) var files: [Item]
    private(set) var contents: [DirectoryIteratorItem]
    
    let url: URL?
    weak private(set) var parent: DirectoryIterator?
    
    init(withURL url: URL?,
         parent: DirectoryIterator? = nil) throws {
        
        self.parent = parent
        self.url = url

        self.directories = []
        self.files = []
        self.contents = []

        if url != nil {
            try self.updateContents()
        }
    }
    
    init() {
        self.parent = nil
        self.url = nil
        self.directories = []
        self.files = []
        self.contents = []
    }
    
    var isDirectory:Bool {
        return true
    }
    
    private func updateContents() throws {
        
        if let parentURL = self.url {
            var files:[Item] = []
            var directories:[DirectoryIterator] = []
            var contents:[DirectoryIteratorItem] = []

            let contentPaths = try FileManager.default.contentsOfDirectory(atPath: parentURL.path)
            for itemPath in contentPaths {
                if itemPath.hasPrefix(".") {
                    continue
                }
                
                let itemURL = parentURL.appendingPathComponent(itemPath)
                
                var isDir : ObjCBool = false
                if FileManager.default.fileExists(atPath: itemURL.path, isDirectory: &isDir) {
                    if isDir.boolValue {
                        let item = try DirectoryIterator(withURL: itemURL,
                                                         parent: self)
                        contents.append(item)
                        directories.append(item)
                    } else {
                        let item = Item(withURL: itemURL, parent: self)
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
    }
    
    typealias Visitor = (_ item: DirectoryIteratorItem, _ depth: Int) -> Void
    
    private func visitEach(depth: Int,
                           visitor: Visitor) {
        
        self.contents.forEach { (item) in
            visitor(item, depth)
            if let dir = item as? DirectoryIterator {
                dir.visitEach(depth: depth + 1, visitor:visitor)
            }
        }
    }
    
    func visitEach(_ visitor: Visitor) {
        visitor(self, 0)
        self.visitEach(depth: 1, visitor: visitor)
    }
    
    var description: String {
        
        var allItems: [String] = []
        
        self.visitEach() { item, depth in
            allItems.append(item.name.prepend(with: " ", count: depth * 4))
        }
        
        let allItemsString = allItems.joined(separator: "\n")
        
        return "\(type(of:self)): \(self.url?.path ?? "nil"):\n\(allItemsString)"
    }
    
    static func == (lhs: DirectoryIterator, rhs: DirectoryIterator) -> Bool {
        return  lhs.url == rhs.url &&
                lhs.directories == rhs.directories &&
                lhs.files == rhs.files
    }
}

extension DirectoryIterator {
    class Item: DirectoryIteratorItem, Equatable, CustomStringConvertible {
        let url: URL?
        weak private(set) var parent: DirectoryIterator?

        init(withURL url: URL?,
             parent: DirectoryIterator?) {
            self.url = url
            self.parent = parent
        }
        
        static func == (lhs: Item, rhs: Item) -> Bool {
            return  lhs.url == rhs.url
        }
       
        var description: String {
            return "\(type(of:self)): url:\(self.url?.path ?? "nil")"
        }
    }
}
