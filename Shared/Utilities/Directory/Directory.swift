//
//  DirectoryTemplate.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/7/21.
//

import Foundation
//
//class Directory: DirectoryItem {
//    
//    private(set) var directories:[Directory]
//    private(set) var files: [Directory.File]
//    private(set) var contents: [DirectoryItem]
//    
//    convenience init(withURL url: URL,
//                     parent: Directory? = nil) throws {
//     
//        try self.init(withID: url.absoluteString,
//                      url:url, parent: parent)
//    }
//
//    init(withID id: String,
//         url: URL,
//         parent: Directory? = nil) throws {
//        
//        self.directories = []
//        self.files = []
//        self.contents = []
//
//        super.init(withID: id,
//                   url:url,
//                   isDirectory: true,
//                   parent:parent)
//        
//        try self.updateContents()
//    }
//    
//    func createDirectory(withURL url: URL, parent: Directory?) throws -> Directory {
//        return try Directory(withID: url.absoluteString,
//                             url: url,
//                             parent: parent)
//    }
//
//    func createFile(withURL url: URL, parent: Directory) -> Directory.File {
//        return Directory.File(withID: url.absoluteString,
//                    url: url,
//                    parent: parent)
//    }
//
//    func updateContents() throws {
//        
//        var files:[Directory.File] = []
//        var directories:[Directory] = []
//        var contents:[DirectoryItem] = []
//
//        let contentPaths = try FileManager.default.contentsOfDirectory(atPath: url.path)
//        for itemPath in contentPaths {
//            if itemPath.hasPrefix(".") {
//                continue
//            }
//            
//            let itemURL = url.appendingPathComponent(itemPath)
//            
//            var isDir : ObjCBool = false
//            if FileManager.default.fileExists(atPath: itemURL.path, isDirectory: &isDir) {
//                if isDir.boolValue {
//                    let item = try self.createDirectory(withURL: itemURL, parent: self)
//                    contents.append(item)
//                    directories.append(item)
//                } else {
//                    let item = self.createFile(withURL: itemURL, parent: self)
//                    contents.append(item)
//                    files.append(item)
//                }
//            }
//        }
//        
//        self.contents = contents.sorted(by: { lhs, rhs in
//            lhs.name.localizedCaseInsensitiveCompare(rhs.name) == ComparisonResult.orderedAscending
//        })
//        
//        self.files = files.sorted { lhs, rhs in
//            lhs.name.localizedCaseInsensitiveCompare(rhs.name) == ComparisonResult.orderedAscending
//        }
//
//        self.directories = directories.sorted { lhs, rhs in
//            lhs.name.localizedCaseInsensitiveCompare(rhs.name) == ComparisonResult.orderedAscending
//        }
//    }
//    
//    typealias Visitor = (_ item: DirectoryItem, _ depth: Int) -> Void
//    
//    private func visitEach(depth: Int,
//                           visitor: Visitor) {
//        
//        self.contents.forEach { (item) in
//            visitor(item, depth)
//            if let dir = item as? Directory {
//                dir.visitEach(depth: depth + 1, visitor:visitor)
//            }
//        }
//    }
//    
//    func visitEach(_ visitor: Visitor) {
//        visitor(self, 0)
//        self.visitEach(depth: 1, visitor: visitor)
//    }
//    
//    override var description: String {
//        
//        var allItems: [String] = []
//        
//        self.visitEach() { item, depth in
//            allItems.append(item.name.prepend(with: " ", count: depth * 4))
//        }
//        
//        let allItemsString = allItems.joined(separator: "\n")
//        
//        return "\(type(of:self)): \(self.url.path):\n\(allItemsString)"
//    }
//    
//    static func == (lhs: Directory, rhs: Directory) -> Bool {
//        return  lhs.url == rhs.url &&
//                lhs.directories == rhs.directories &&
//                lhs.files == rhs.files
//    }
//    
//}
//
//extension Directory {
//    class File : DirectoryItem {
//        init(withURL url: URL,
//             parent: Directory?) {
//            super.init(withID: url.absoluteString, url: url, isDirectory: false, parent: parent)
//        }
//        
//        init(withID id: String,
//             url: URL,
//             parent: Directory?) {
//            super.init(withID: id, url: url, isDirectory: false, parent: parent)
//        }
//
//        static func == (lhs: Directory.File, rhs: Directory.File) -> Bool {
//            return  lhs.url == rhs.url
//        }
//    }
//}
