//
//  SoundFolder+DirectoryIterator.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/11/21.
//

import Foundation

extension SoundFolder {

    private static func cleanupName(_ url: URL?) -> String {
        if let theURL = url {
            
            var cleanedName = theURL.deletingPathExtension().lastPathComponent
            
            [ "-", "_" ].forEach { cleanedName = cleanedName.replacingOccurrences(of: $0, with: " ")}

            return cleanedName
        }
        
        return ""
    }

    convenience init(withDirectory directory: DirectoryIterator) {
        
        self.init(withID: UUID().uuidString,
                  url: directory.url,
                  displayName: Self.cleanupName(directory.url))
        
        for file in directory.files {
            let url = file.url
            self.addSound(SoundFile(withID:String.guid,
                                    url: url,
                                    displayName: Self.cleanupName(url),
                                    randomizer: RandomizationDescriptor.none))
        }

        for directory in directory.directories {
            self.addSubFolder(SoundFolder(withDirectory: directory))
        }
    }
}

