//
//  SoundFolder+DirectoryIterator.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/11/21.
//

import Foundation

extension URL {
    static var soundExtensions: [String] {
        return [ "wav", "mp3" ]
    }
    
    var isSoundFile: Bool {
        if let _ = Self.soundExtensions.firstIndex(where: { $0 == self.pathExtension } ) {
            return true
        }

        return false
    }
    
}

extension SoundFolder {
    
    convenience init(withDirectory directory: DirectoryIterator) throws {
        let descriptor = try SoundFolderItemDescriptor.read(fromURL: Self.descriptorFileURL(forURL: directory.url))
        self.init(withDescriptor: descriptor, atPath: directory.url)
        try self.addContents(inDirectory: directory)
    }
    
    private func addContents(inDirectory directory: DirectoryIterator) throws {
        for file in directory.files {
            if file.url.isSoundFile {
                let fileDescriptor = try SoundFolderItemDescriptor.read(fromURL: SoundFile.descriptorFileURL(forURL: file.url))
                let soundFile = SoundFile(withDescriptor: fileDescriptor, atPath: file.url)
                self.addSoundFile(soundFile)
            }
        }

        for directory in directory.directories {
            self.addSubFolder(try SoundFolder(withDirectory: directory))
        }
    }

}
