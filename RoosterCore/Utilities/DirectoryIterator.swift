//
//  DirectoryTemplate.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/7/21.
//

import Foundation

public protocol DirectoryIteratorItem: AnyObject {
    var isDirectory: Bool { get }
    var url: URL { get }
    var name: String { get }
    var parent: DirectoryIterator? { get }
}

extension DirectoryIteratorItem {
    public var isDirectory:Bool {
        return false
    }
    
    public var name: String {
        return self.url.lastPathComponent
    }
    
    public var relativePath: String {
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

public class DirectoryIterator: DirectoryIteratorItem, Equatable, CustomStringConvertible {
    
    private(set) public var directories:[DirectoryIterator]
    private(set) public var files: [Item]
    private(set) public var contents: [DirectoryIteratorItem]
    
    public let url: URL
    public weak private(set) var parent: DirectoryIterator?
    
    public init(withURL url: URL,
                parent: DirectoryIterator? = nil) throws {
        
        self.parent = parent
        self.url = url

        self.directories = []
        self.files = []
        self.contents = []

        try self.updateContents()
    }
    
    public init() {
        self.parent = nil
        self.url = URL.emptyRoosterURL
        self.directories = []
        self.files = []
        self.contents = []
    }
    
    public var isDirectory:Bool {
        return true
    }
    
    private func updateContents() throws {
        let parentURL = self.url
        if !parentURL.isRoosterURL {
            
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
    
    public typealias Visitor = (_ item: DirectoryIteratorItem, _ depth: Int) -> Void
    
    private func visitEach(depth: Int,
                           visitor: Visitor) {
        
        self.contents.forEach { (item) in
            visitor(item, depth)
            if let dir = item as? DirectoryIterator {
                dir.visitEach(depth: depth + 1, visitor:visitor)
            }
        }
    }
    
    public func visitEach(_ visitor: Visitor) {
        visitor(self, 0)
        self.visitEach(depth: 1, visitor: visitor)
    }
    
    public var description: String {
        
        var allItems: [String] = []
        
        self.visitEach() { item, depth in
            allItems.append(item.name.prepend(with: " ", count: depth * 4))
        }
        
        let allItemsString = allItems.joined(separator: "\n")
        
        return "\(type(of:self)): \(self.url.absoluteString):\n\(allItemsString)"
    }
    
    public static func == (lhs: DirectoryIterator, rhs: DirectoryIterator) -> Bool {
        return  lhs.url == rhs.url &&
                lhs.directories == rhs.directories &&
                lhs.files == rhs.files
    }
}

extension DirectoryIterator {
    
    public class Item: DirectoryIteratorItem, Equatable, CustomStringConvertible {
        public let url: URL
        public weak private(set) var parent: DirectoryIterator?

        public init(withURL url: URL,
             parent: DirectoryIterator?) {
            self.url = url
            self.parent = parent
        }
        
        public static func == (lhs: Item, rhs: Item) -> Bool {
            return  lhs.url == rhs.url
        }
       
        public var description: String {
            return "\(type(of:self)): url:\(self.url.absoluteString)"
        }
    }
}
