//
//  SoundResources.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/10/21.
//

import Foundation

struct SoundFolder {
    
    let folderURL: URL
    let soundURLs: [URL]
    let subFolders: [SoundFolder]
    
    var disclosed: Bool = true
    
    static func loadFromBundle() -> SoundFolder {
        if  let resourcePath = Bundle.main.resourceURL {
            let soundPath = resourcePath.appendingPathComponent("Sounds")
            
            if let folder = self.loadFolderForPath(soundPath) {
                return folder
            }
        }
        
        return SoundFolder(folderURL: URL(fileURLWithPath: ""), soundURLs: [], subFolders: [])
    }
    
    private static func loadFolderForPath(_ url: URL) -> SoundFolder? {
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: url.path)
            
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
                        
                        if let newFolder = self.loadFolderForPath(filePath) {
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
                lhs.folderURL.fileName.localizedCaseInsensitiveCompare(rhs.folderURL.fileName) == ComparisonResult.orderedAscending
            }

            return SoundFolder(folderURL: url,
                               soundURLs: sortedSounds,
                               subFolders: sortedFolders)
            
        } catch {
        }
        
        return nil
    }
    
    var allUrls: [URL] {
        
        var urls: [URL] = []
        
        self.soundURLs.forEach() { urls.append($0) }
        
        self.subFolders.forEach() { urls.append(contentsOf: $0.allUrls) }

        let sortedSounds = urls.sorted { lhs, rhs in
            lhs.absoluteString.localizedCaseInsensitiveCompare(rhs.absoluteString) == ComparisonResult.orderedAscending
        }

        return sortedSounds
    }
    
}

extension Bundle {
    static var availableSoundResources: [URL] = {
        return SoundFolder.loadFromBundle().allUrls
    }()
}

extension URL {
    var soundName: String {
        return self.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "-", with: " ").replacingOccurrences(of: "_", with: " ")
    }
}

extension SoundPreferences {
    
    var soundURLs: [URL] {
        
        var outURLs:[URL] = []
        
//        let availableURLs = Bundle.availableSoundResources
        
        for sound in self {
            
            if sound.random {
                outURLs.append(URL.randomizedSound)
                continue
            }

            if let soundURL = sound.url {
                outURLs.append(soundURL)
            }
            
//            for url in availableURLs {
//                if url == sound.url {
//                    outURLs.append(url)
//                }
//            }
        }
        
        return outURLs
    }
    
    static var availableSounds: [String] {
        let availableURLs = Bundle.availableSoundResources
        return availableURLs.map { $0.soundName }
    }
    
    static var availableSoundURLs: [URL] {
        return Bundle.availableSoundResources
    }
    
    static func urlForName(_ name: String) -> URL? {
        for url in self.availableSoundURLs {
            if url.fileName == name || url.soundName == name {
                return url
            }
        }
        
        return nil
    }
}
