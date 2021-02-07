//
//  SoundFile.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/3/21.
//

import Foundation

class SoundFile: CustomStringConvertible, Identifiable {
    
    typealias ID = String
    
    weak var folder: SoundFolder?
    
    let id: String
    let url: URL
    let isRandom: Bool

    init(with url: URL, folder: SoundFolder?, isRandom random: Bool) {
        self.folder = folder
        self.url = url
        self.id = "\(folder?.id ?? "")/\(self.url.fileName)"
        self.isRandom = random
    }
    
    var name: String {
        return self.url.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "-", with: " ").replacingOccurrences(of: "_", with: " ")
    }
    
    var description: String {
        return "\(type(of:self)): \(self.id), name: \(self.name), url: \(self.url), isRandom:\(self.isRandom), parent: \(self.folder?.description ?? "nil")"
    }
    
    var displayName: String {
        return self.url.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "-", with: " ").replacingOccurrences(of: "_", with: " ")
    }
}
