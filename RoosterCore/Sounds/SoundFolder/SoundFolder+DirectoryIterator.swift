//
//  SoundFolder+DirectoryIterator.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/11/21.
//

import Foundation

extension URL {
    public static var soundExtensions: [String] {
        return [ "wav", "mp3" ]
    }
    
    public var isSoundFile: Bool {
        if let _ = Self.soundExtensions.firstIndex(where: { $0 == self.pathExtension } ) {
            return true
        }

        return false
    }
    
}

extension SoundFolder {
    
    public convenience init(withDirectory directory: DirectoryIterator) throws {
        let descriptor = try SoundFolderDescriptor.read(fromURL: directory.url)
        self.init(withDescriptor: descriptor, atPath: directory.url)
        try self.addContents(inDirectory: directory)
    }
    
    private func addContents(inDirectory directory: DirectoryIterator) throws {
        for file in directory.files {
            if file.url.isSoundFile {
                let fileDescriptor = try SoundFileDescriptor.read(fromURL:file.url)
                let soundFile = SoundFile(withDescriptor: fileDescriptor, atPath: file.url)
                self.addSoundFile(soundFile)
            }
        }

        for directory in directory.directories {
            self.addSubFolder(try SoundFolder(withDirectory: directory))
        }
    }

}
