//
//  SoundFolder+Bundle.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/11/21.
//

import Foundation

extension SoundFolder {
    
    static var defaultSoundFolderID = "de94d3de-5a26-4fda-9db8-384744844b69"
    
    static func loadFromBundle() -> SoundFolder {
        if  let resourcePath = Bundle.main.resourceURL {
            let soundPath = resourcePath.appendingPathComponent("Sounds")
            
            do {
                let directory = try DirectoryIterator(withURL: soundPath)
                let soundFolder = SoundFolder(withDirectory: directory)
                soundFolder.id = Self.defaultSoundFolderID
                return soundFolder
            } catch {
                self.logger.error("Creating SoundFolder failed with error: \(error.localizedDescription)")
            }
        }
        
        return SoundFolder.empty
    }
    
    var isDefaultSoundFolder: Bool {
        return self.id == Self.defaultSoundFolderID
    }
}
