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
    
    func findSoundFiles(containing: [String],
                        excluding exactExclusions: [String] = []) -> [SoundFile]? {
        
        var sounds:[SoundFile] = []
        for sound in self.allSoundFiles {
            containing.forEach {
                if sound.searchMatches($0) &&
                    !self.isExcluded(sound.displayName, exactExclusions: exactExclusions){
                    sounds.append(sound)
                }
            }
        }
        return sounds.count > 0 ? sounds: nil
    }
    
    func findSoundFile(forIdentifier id: String) -> SoundFile? {
        for sound in self.allSoundFiles {
            if sound.id == id {
                return sound
            }
        }
        
        return nil
    }
    
    func findSoundFiles(forIdentifiers identifiers: [String]) -> [SoundFile] {
        var outSounds:[SoundFile] = []
        
        identifiers.forEach {
            if let soundFile = self.findSoundFile(forIdentifier: $0) {
                outSounds.append(soundFile)
            }
        }
        
        return outSounds
    }
    
    func findSubFolder(containing name: String) -> SoundFolder? {
        return self.findSubFolder(containing: name, parent: nil)
    }
    
    func findSubFolder(containing searchString: String, parent: SoundFolder?) -> SoundFolder? {
        
        let outFolder = SoundFolder(withID: self.id,
                                    url: URL.roosterURL("search-\(searchString)"),
                                    displayName: self.displayName)
        
        var sounds:[SoundFile] = []
        for sound in self.soundFiles {
            if sound.searchMatches(searchString) {
                sounds.append(sound)
            }
        }
        
        var subFolders: [SoundFolder] = []
        for subFolder in self.subFolders {
            if subFolder.searchMatches(searchString) {
                subFolders.append(subFolder)
            } else if let foundFolder = subFolder.findSubFolder(containing: searchString, parent: self) {
                subFolders.append(foundFolder)
            }
        }
        
        if sounds.count > 0 || subFolders.count > 0 {
            outFolder.setSoundFiles(sounds)
            outFolder.setSubFolders(subFolders)
            
            return outFolder
        }

        return nil
    }

    func findSoundFiles(forName name: String) -> [SoundFile] {
        var sounds: [SoundFile] = []
        
        for sound in self.allSoundFiles {
            if sound.displayName.localizedCaseInsensitiveContains(name) {
                sounds.append(sound)
            }
        }
        
        return sounds
    }
    
    func contains(soundID id: String) -> Bool {
        return self.findSoundFile(forIdentifier: id) != nil
    }
    
}
