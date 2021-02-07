//
//  SoundFile.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/3/21.
//

import Foundation

class SoundFile: CustomStringConvertible, Identifiable {
    
    typealias ID = String
    
    weak var parent: SoundFolder?
    
    let id: String
    let url: URL

    init(withURL url: URL, parent: SoundFolder?) {
        self.parent = parent
        self.url = url
        self.id = "\(parent?.id ?? "")/\(self.url.fileName)"
    }
    
    var name: String {
        return self.url.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "-", with: " ").replacingOccurrences(of: "_", with: " ")
    }
    
    var description: String {
        return "\(type(of:self)): \(self.id), name: \(self.name), url: \(self.url), parent: \(self.parent?.description ?? "nil")"
    }
    
    var displayName: String {
        return self.url.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "-", with: " ").replacingOccurrences(of: "_", with: " ")
    }
}
