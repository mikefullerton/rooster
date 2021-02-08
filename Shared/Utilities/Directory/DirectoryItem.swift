//
//  DirectoryItem.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/7/21.
//

import Foundation

protocol DirectoryItemProtocol: AnyObject {
    associatedtype DirectoryType
    
    var url: URL? { get }
    var id: String { get }
    var parent: DirectoryType? { get }
    var name: String { get }

    init(withID id: String,
         url: URL?,
         parent: DirectoryType?)

}

class DirectoryItem: DirectoryItemProtocol, Identifiable, Hashable, Equatable, Loggable {

    typealias ID = String
    typealias DirectoryType = 
    
    let url: URL?
    let id: String
    
    weak private(set) var parent: DirectoryProtocol?

    required init(withID id: String,
         url: URL?,
         parent: DirectoryProtocol?) {
        self.id = id
        self.url = url
        self.parent = parent
    }
    
    var isDirectory: Bool {
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    static func == (lhs: DirectoryItem, rhs: DirectoryItem) -> Bool {
        return  lhs.url == rhs.url &&
                lhs.id == rhs.id
    }
   
    var description: String {
        return "\(type(of:self)): id: \(self.id), url:\(self.url?.path ?? "")"
    }
}
