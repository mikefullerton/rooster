//
//  SoundFile.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/3/21.
//

import Foundation

class SoundFile: CustomStringConvertible {
    
    weak var folder: SoundFolder?
    
    let identifier: String
    let url: URL
    let isRandom: Bool

    init(with url: URL, folder: SoundFolder?, isRandom random: Bool) {
        self.folder = folder
        self.url = url
        self.identifier = "\(folder?.identifier ?? "")/\(self.url.fileName)"
        self.isRandom = random
    }
    
    var name: String {
        return self.url.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "-", with: " ").replacingOccurrences(of: "_", with: " ")
    }
    
    var description: String {
        return "Sound: \(self.identifier), name: \(self.name), url: \(self.url), isRandom:\(self.isRandom), parent: \(self.folder?.description ?? "nil")"
    }
    
    var displayName: String {
        return self.url.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "-", with: " ").replacingOccurrences(of: "_", with: " ")
    }
}
