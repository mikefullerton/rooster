//
//  SoundFolder+Searching.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/11/21.
//

import Foundation

extension SoundFolder {
    private func isExcluded(_ searchString: String, exactExclusions: [String]) -> Bool {
        if exactExclusions.isEmpty {
            return false
        }

        if exactExclusions.contains(where: { $0.caseInsensitiveCompare(searchString) == .orderedSame }) {
            return true
        }

        return false
    }

    public func findSoundFiles(containing: [String],
                               excluding exactExclusions: [String] = []) -> [SoundFile]? {
        var sounds: [SoundFile] = []
        for sound in self.allSoundFiles {
            containing.forEach {
                if sound.searchMatches($0) &&
                    !self.isExcluded(sound.displayName, exactExclusions: exactExclusions) {
                    sounds.append(sound)
                }
            }
        }
        return sounds.isEmpty ? nil : sounds
    }

    public func findSoundFile(forIdentifier id: String) -> SoundFile? {
//        if id == SoundFile.randomSoundID {
//            let soundFile = SoundFile.random
//            soundFile.setParent(self)
//            return soundFile
//        }

        for sound in self.allSoundFiles where sound.id == id {
            return sound
        }

        return nil
    }

    public func findSoundFiles(forIdentifiers identifiers: [String]) -> [SoundFile] {
        var outSounds: [SoundFile] = []

        identifiers.forEach {
            if let soundFile = self.findSoundFile(forIdentifier: $0) {
                outSounds.append(soundFile)
            }
        }

        return outSounds
    }

    public func findSubFolder(containing name: String) -> SoundFolder? {
        self.findSubFolder(containing: name, parent: nil)
    }

    // swiftlint:disable force_cast

    public func findSubFolder(containing searchString: String, parent: SoundFolder?) -> SoundFolder? {
        var sounds: [SoundFile] = []
        for sound in self.soundFiles {
            if sound.searchMatches(searchString) {
                sounds.append(sound.copy() as! SoundFile)
                self.logger.log("Found matching sound: \(sound.description) in folder: \(self.description)")
            }
        }

        var subFolders: [SoundFolder] = []
        for subFolder in self.subFolders {
            if subFolder.searchMatches(searchString) {
                subFolders.append(subFolder.copy() as! SoundFolder)

                self.logger.log("Found matching subfolder: \(subFolder.description) in folder: \(self.description)")
            } else if let foundFolder = subFolder.findSubFolder(containing: searchString, parent: self) {
                subFolders.append(foundFolder.copy() as! SoundFolder)

                self.logger.log("Found subfolder with matching contents: \(foundFolder.description) in folder: \(self.description)")
            }
        }

        if !sounds.isEmpty || !subFolders.isEmpty {
            let outFolder = SoundFolder(withID: self.id,
                                        directoryPath: self.absolutePath ?? URL.empty,
                                        displayName: self.displayName)

            outFolder.addSoundFiles(sounds)
            outFolder.addSubFolders(subFolders)
            return outFolder
        }

        return nil
    }

    // swiftlint:enable force_cast

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
        self.findSoundFile(forIdentifier: id) != nil
    }
}
