//
//  DirectoryItem.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/7/21.
//

import Foundation

//class DirectoryItem: Loggable, Identifiable, Equatable, Hashable {
//
//    typealias ID = String
//
//    let url: URL
//    let id: String
//    let isDirectory: Bool
//    
//    weak private(set) var parent: Directory?
//
//    init(withID id: String,
//         url: URL,
//         isDirectory: Bool,
//         parent: Directory?) {
//        self.id = id
//        self.url = url
//        self.isDirectory = isDirectory
//        self.parent = parent
//    }
//    
//    var name: String {
//        return self.url.lastPathComponent
//    }
//    
//    var relativePath: String {
//        var names:[String] = []
//        
//        names.append(self.name)
//        
//        var walker = self.parent
//        
//        while (walker != nil) {
//            names.append(walker!.name)
//            walker = walker!.parent
//        }
//        
//        return names.reversed().joined(separator: "/")
//    }
//    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(self.id)
//    }
//    
//    static func == (lhs: DirectoryItem, rhs: DirectoryItem) -> Bool {
//        return  lhs.url == rhs.url &&
//                lhs.id == rhs.id
//    }
//   
//    var description: String {
//        return "\(type(of:self)): id: \(self.id), url:\(self.url.path)"
//    }
//}
