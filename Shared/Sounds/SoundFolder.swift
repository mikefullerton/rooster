//
//  SoundResources.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/10/21.
//

import Foundation

class SoundFolder: CustomStringConvertible {
    
    static let instance = SoundFolder.loadFromBundle()
    
    let url: URL?
    private(set) var sounds: [SoundFile]
    private(set) var subFolders: [SoundFolder]
    weak private(set) var parent: SoundFolder?
    
    var identifier: String {
        if let parent = self.parent {
            return "\(parent.identifier)/\(self.url?.lastPathComponent ?? "")"
        }
        
        return self.url?.lastPathComponent ?? ""
    }
    
    var name: String {
        return self.url?.fileName ?? ""
    }
    
    var disclosed: Bool = true
    
    static let empty = SoundFolder(with: nil, parent: nil)
    
    private init(with url: URL?, parent: SoundFolder?) {
        self.parent = parent
        self.url = url
        self.sounds = []
        self.subFolders = []
    }
    
    private static func loadFromBundle() -> SoundFolder {
        if  let resourcePath = Bundle.main.resourceURL {
            let soundPath = resourcePath.appendingPathComponent("Sounds")
            
            if let folder = self.loadFolderForPath(soundPath, parent: nil) {
                return folder
            }
        }
        
        return SoundFolder(with: URL(fileURLWithPath: ""), parent: nil)
    }
    
    private static func loadFolderForPath(_ url: URL, parent: SoundFolder?) -> SoundFolder? {
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: url.path)
            
            let folder = SoundFolder(with: url, parent: parent)
            
            var urls:[URL] = []
            var subfolders:[SoundFolder] = []
            
            for file in contents {
                if file.hasPrefix(".") {
                    continue
                }
                
                let filePath = url.appendingPathComponent(file)
                
                var isDir : ObjCBool = false
                if FileManager.default.fileExists(atPath: filePath.path, isDirectory: &isDir) {
                    if isDir.boolValue {
                        
                        if let newFolder = self.loadFolderForPath(filePath, parent: folder) {
                            subfolders.append(newFolder)
                        }
                    } else {
                        urls.append(filePath)
                    }
                }
            }
            
            let sortedSounds = urls.sorted { lhs, rhs in
                lhs.fileName.localizedCaseInsensitiveCompare(rhs.fileName) == ComparisonResult.orderedAscending
            }

            let sortedFolders = subfolders.sorted { lhs, rhs in
                lhs.name.localizedCaseInsensitiveCompare(rhs.name) == ComparisonResult.orderedAscending
            }

            folder.sounds = sortedSounds.map { SoundFile(with: $0, folder: folder, isRandom: false) }
            folder.subFolders = sortedFolders
            return folder
            
        } catch {
        }
        
        return nil
    }
    
    lazy var allSounds: [SoundFile] = {
        
        var sounds: [SoundFile] = []
        
        self.sounds.forEach() { sounds.append($0) }
        
        self.subFolders.forEach() { sounds.append(contentsOf: $0.allSounds) }

        let sortedSounds = sounds.sorted { lhs, rhs in
            lhs.identifier.localizedCaseInsensitiveCompare(rhs.identifier) == ComparisonResult.orderedAscending
        }

        return sortedSounds
    }()
    
    func findSounds(forName name: String) -> [SoundFile] {
        var sounds: [SoundFile] = []
        
        for sound in self.allSounds {
            if sound.name.localizedCaseInsensitiveContains(name) {
                sounds.append(sound)
            }
        }
        
        return sounds
    }
    
    func findSound(forIdentifier identifier: String) -> SoundFile? {
        for sound in self.allSounds {
            if sound.identifier == identifier {
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
    
    func findFolder(containing name: String, parent: SoundFolder?) -> SoundFolder? {
    
        let outFolder = SoundFolder(with: self.url, parent: parent)
        
        if parent != nil && outFolder.name.localizedCaseInsensitiveContains(name) {
            outFolder.sounds = self.sounds
            outFolder.subFolders = self.subFolders
            return outFolder
        }
        
        var sounds:[SoundFile] = []
        
        for sound in self.sounds {
            if sound.name.localizedCaseInsensitiveContains(name) {
                sounds.append(sound)
            }
        }
        
        var subFolders: [SoundFolder] = []
        
        for subFolder in self.subFolders {
            if let foundFolder = subFolder.findFolder(containing: name, parent: outFolder) {
                subFolders.append(foundFolder)
            }
        }
        
        if sounds.count > 0 || subFolders.count > 0 {
            outFolder.sounds = sounds
            outFolder.subFolders = subFolders
            
            return outFolder
        }

        return nil
    }
    
    var randomSound: SoundFile {
        let soundFile = self.allSounds.randomElement()!
        return SoundFile(with: soundFile.url, folder: soundFile.folder!, isRandom: true)
    }
    
    var description: String {
        return "SoundFolder: \(self.identifier), name: \(self.name), url: \(String(describing:self.url)), parent: \(self.parent?.description ?? "nil"), soundCount: \(self.sounds.map { $0.identifier }), subFolders:\(self.subFolders.map { $0.identifier })"
    }
}

