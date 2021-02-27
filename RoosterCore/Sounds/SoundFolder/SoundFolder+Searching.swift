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
    
    public func findSoundFiles(containing: [String],
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
    
    public func findSoundFile(forIdentifier id: String) -> SoundFile? {
        for sound in self.allSoundFiles {
            if sound.id == id {
                return sound
            }
        }
        
        return nil
    }
    
    public func findSoundFiles(forIdentifiers identifiers: [String]) -> [SoundFile] {
        var outSounds:[SoundFile] = []
        
        identifiers.forEach {
            if let soundFile = self.findSoundFile(forIdentifier: $0) {
                outSounds.append(soundFile)
            }
        }
        
        return outSounds
    }
    
    public func findSubFolder(containing name: String) -> SoundFolder? {
        return self.findSubFolder(containing: name, parent: nil)
    }
    
    public func findSubFolder(containing searchString: String, parent: SoundFolder?) -> SoundFolder? {

        var sounds:[SoundFile] = []
        for sound in self.soundFiles {
            if sound.searchMatches(searchString) {
                sounds.append(sound.copy() as! SoundFile)
            }
        }

        var subFolders: [SoundFolder] = []
        for subFolder in self.subFolders {
            if subFolder.searchMatches(searchString) {
                subFolders.append(subFolder.copy() as! SoundFolder)
            } else if let foundFolder = subFolder.findSubFolder(containing: searchString, parent: self) {
                subFolders.append(foundFolder.copy() as! SoundFolder)
            }
        }

        if sounds.count > 0 || subFolders.count > 0 {
            let outFolder = SoundFolder(withID: self.id,
                                        directoryName: self.directoryName,
                                        displayName: self.displayName,
                                        sounds: sounds,
                                        subFolders: subFolders)

            return outFolder
        }

        return nil
    }

    public func findSoundFiles(forName name: String) -> [SoundFile] {
        var sounds: [SoundFile] = []
        
        for sound in self.allSoundFiles {
            if sound.displayName.localizedCaseInsensitiveContains(name) {
                sounds.append(sound)
            }
        }
        
        return sounds
    }
    
    public func contains(soundID id: String) -> Bool {
        return self.findSoundFile(forIdentifier: id) != nil
    }
    
}
