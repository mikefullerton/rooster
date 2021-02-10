//
//  SoundFolder+Searching.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/11/21.
//

import Foundation

extension SoundFolder {
    private func isExcluded(_ searchString: String, exactExclusions: [String]) -> Bool {
        if exactExclusions.count == 0 {
            return false
        }
        
        if let _ = exactExclusions.firstIndex(where: { $0.caseInsensitiveCompare(searchString) == .orderedSame }) {
            return true
        }
        
        return false
        
    }
    
    func findSounds(containing: [String],
                    excluding exactExclusions: [String] = []) -> [SoundFile]? {
        
        var sounds:[SoundFile] = []
        for sound in self.allSounds {
            containing.forEach {
                if sound.searchMatches($0) &&
                    !self.isExcluded(sound.displayName, exactExclusions: exactExclusions){
                    sounds.append(sound)
                }
            }
        }
        return sounds.count > 0 ? sounds: nil
    }
    
    func findSound(forIdentifier id: String) -> SoundFile? {
        for sound in self.allSounds {
            if sound.id == id {
                return sound
            }
        }
        
        return nil
    }
    
    func findSounds(forIdentifiers identifiers: [String]) -> [SoundFile] {
        var outSounds:[SoundFile] = []
        
        identifiers.forEach {
            if let soundFile = self.findSound(forIdentifier: $0) {
                outSounds.append(soundFile)
            }
        }
        
        return outSounds
    }
    
    func findFolder(containing name: String) -> SoundFolder? {
        return self.findFolder(containing: name, parent: nil)
    }
    
    func findFolder(containing searchString: String, parent: SoundFolder?) -> SoundFolder? {
        
        let outFolder = SoundFolder(withID: self.id,
                                    url: URL.roosterURL("search-\(searchString)"),
                                    displayName: self.displayName)
        
        var sounds:[SoundFile] = []
        for sound in self.sounds {
            if sound.searchMatches(searchString) {
                sounds.append(sound)
            }
        }
        
        var subFolders: [SoundFolder] = []
        for subFolder in self.subFolders {
            if subFolder.searchMatches(searchString) {
                subFolders.append(subFolder)
            } else if let foundFolder = subFolder.findFolder(containing: searchString, parent: self) {
                subFolders.append(foundFolder)
            }
        }
        
        if sounds.count > 0 || subFolders.count > 0 {
            outFolder.setSounds(sounds)
            outFolder.setSubFolders(subFolders)
            
            return outFolder
        }

        return nil
    }

    func findSounds(forName name: String) -> [SoundFile] {
        var sounds: [SoundFile] = []
        
        for sound in self.allSounds {
            if sound.displayName.localizedCaseInsensitiveContains(name) {
                sounds.append(sound)
            }
        }
        
        return sounds
    }
    
    func contains(soundID id: String) -> Bool {
        return self.findSound(forIdentifier: id) != nil
    }
    
}
