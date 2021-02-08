//
//  DirectoryTemplate.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/7/21.
//

import Foundation

protocol DirectoryProtocol: DirectoryItemProtocol {
    var directories:[DirectoryProtocol] { get }
    var files: [DirectoryItemProtocol] { get }
    var contents: [DirectoryItemProtocol] { get }
    
    init(withID id: String,
         url: URL) throws
}

protocol DirectoryFactory: AnyObject {
    func directory(_ directory: Directory, createDirectoryWithURL url: URL, parent: Directory?) throws -> DirectoryProtocol
    func directory(_ directory: Directory, createFileWithURL url: URL, parent: Directory?) -> DirectoryItemProtocol
}

final class Directory: DirectoryItem, DirectoryProtocol {
    weak var factory: DirectoryFactory?
    
    private(set) var directories:[DirectoryProtocol]
    private(set) var files: [DirectoryItemProtocol]
    private(set) var contents: [DirectoryItemProtocol]

    required init(withID id: String,
                  url: URL?,
                  parent: DirectoryProtocol? = nil) {

        self.directories = []
        self.files = []
        self.contents = []

        super.init(withID: id,
                   url:url,
                   parent:parent)
    }

    init() {
        self.directories = []
        self.files = []
        self.contents = []

        super.init(withID: "", url: nil, parent: nil)
    }
    
    init(withID id: String,
         url: URL,
         factory: DirectoryFactory? = nil) throws {

        self.factory = factory
        self.directories = []
        self.files = []
        self.contents = []

        super.init(withID: id, url: url, parent: nil)
        
        try self.readContentsFromDisk()
    }
    
    override var isDirectory: Bool {
        return true
    }
    
   

    typealias Visitor = (_ item: DirectoryItemProtocol, _ depth: Int) -> Void

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

        return "\(type(of:self)): \(self.url?.path ?? "nil"):\n\(allItemsString)"
    }

    static func == (lhs: Directory, rhs: Directory) -> Bool {
        return  lhs.url == rhs.url
            
//            &&
//                lhs.directories == rhs.directories &&
//                lhs.files == rhs.files
    }
}

class TypedDirectory<ITEM_TYPE, FILE_TYPE, DIR_TYPE> : DirectoryFactory where DIR_TYPE: DirectoryProtocol, FILE_TYPE:DirectoryItemProtocol, ITEM_TYPE:DirectoryItemProtocol {
    
    private let directory: Directory
    
    init() {
        self.directory = Directory()
    }
    
    required init(withID id: String,
         url: URL) throws {

        self.directory = try Directory(withID: id, url: url, factory: self)
    }
    
    lazy var directories: [DIR_TYPE] = {
        var contents:[DIR_TYPE] = []
        
        self.directory.directories.forEach {
            if let content = $0 as? DIR_TYPE {
                contents.append(content)
            }
        }
        
        return contents
    }()

    lazy var files: [FILE_TYPE] = {
        var contents:[FILE_TYPE] = []
        
        self.directory.files.forEach {
            if let content = $0 as? FILE_TYPE {
                contents.append(content)
            }
        }
        
        return contents
    }()
   
    lazy var contents: [ITEM_TYPE] = {
        var contents:[ITEM_TYPE] = []
        
        self.directory.contents.forEach {
            if let content = $0 as? ITEM_TYPE {
                contents.append(content)
            }
        }
        
        return contents
    }()
    
    var name: String {
        return self.directory.name
    }
    
    var parent: DIR_TYPE? {
        return self.directory.parent as? DIR_TYPE
    }
    
    var url: URL? {
        return self.directory.url
    }
    
    var id: String {
        return self.directory.id
    }
    
    static func == (lhs: TypedDirectory<ITEM_TYPE, FILE_TYPE, DIR_TYPE>, rhs: TypedDirectory<ITEM_TYPE, FILE_TYPE, DIR_TYPE>) -> Bool {
        return lhs.directory == rhs.directory
    }
    
    func directory(_ directory: Directory, createDirectoryWithURL url: URL, parent: Directory?) throws -> DirectoryProtocol {
        return try DIR_TYPE(withID: url.absoluteString, url:url)
    }
    
    func directory(_ directory: Directory, createFileWithURL url: URL, parent: Directory?) -> DirectoryItemProtocol {
        return FILE_TYPE(withID: url.absoluteString, url: url, parent: parent)
    }
}

struct DirectoryIterator<ItemType, DirType> {
    
    let directory: Directory
    
    init(directory: Directory) {
        self.directory = directory
    }
    
    typealias Visitor = (_ item: ItemType, _ depth: Int) -> Void
    
    func visitEach(_ visitor: Visitor) {
        self.directory.visitEach { item, depth in
            if let typedItem = item as? ItemType {
                visitor(typedItem, depth)
            }
        }
    }
}
