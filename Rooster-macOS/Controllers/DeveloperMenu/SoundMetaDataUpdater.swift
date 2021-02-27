//
//  SoundMetaDataUpdater.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/7/21.
//

import Foundation
import RoosterCore

class SoundMetaDataUpdater: DeveloperAction, Loggable {
    
    let soundsPath = "Resources/Sounds"
    
    func run() {
    
        if let roosterURL = self.findRoosterProjectDirectory() {
            let soundsURL = roosterURL.appendingPathComponent(self.soundsPath)
            guard FileManager.default.directoryExists(atURL: soundsURL) else {
                self.showErrorAlert(withMessage: "Can't find Sounds folder!", info: "WTH!")
                return
            }
            
            do {
                let dir = try DirectoryIterator(withURL: soundsURL)

                let soundFolder = try SoundFolder(withCreatingDescriptorsInDirectory: dir, withID: SoundFolder.defaultSoundFolderID)

//                let soundFolderDictionary = soundFolder.asDictionary
//
//                let soundFolderURL = soundsURL.deletingLastPathComponent().appendingPathComponent("Sounds.json")
//
//                try soundFolderDictionary.writeJSON(toURL: soundFolderURL)
//
                print("\(soundFolder.debugDescription)")
                
            } catch {
                self.showErrorAlert(withMessage: "\(error)", info: "")
            }
            
        }
    }
}


extension SoundFolder {

    convenience init(withCreatingDescriptorsInDirectory directory: DirectoryIterator, withID identifier: String) throws {
        let descriptor = try SoundFolderItemDescriptor.readOrCreateDescriptor(atURL: Self.descriptorFileURL(forURL: directory.url), withID: identifier)
        self.init(withDescriptor: descriptor, atPath: directory.url)
        try self.addContentsWithCreatingDescriptors(inDirectory: directory)
    }
    
    convenience init(withCreatingDescriptorsInDirectory directory: DirectoryIterator) throws {
        let descriptor = try SoundFolderItemDescriptor.readOrCreateDescriptor(atURL: Self.descriptorFileURL(forURL: directory.url))
        self.init(withDescriptor: descriptor, atPath: directory.url)
        try self.addContentsWithCreatingDescriptors(inDirectory: directory)
    }
    
    private func addContentsWithCreatingDescriptors(inDirectory directory: DirectoryIterator) throws {
        for file in directory.files {
            
            if file.url.isSoundFile {
                
                let fileDescriptor = try SoundFolderItemDescriptor.readOrCreateDescriptor(atURL: SoundFile.descriptorFileURL(forURL: file.url))
                
                let soundFile = SoundFile(withDescriptor: fileDescriptor, atPath: file.url)
                
                self.addSoundFile(soundFile)
            }
            
        }

        for directory in directory.directories {
            self.addSubFolder(try SoundFolder(withCreatingDescriptorsInDirectory: directory))
        }
    }

}
