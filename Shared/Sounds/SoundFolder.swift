//
//  SoundResources.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/10/21.
//

import Foundation

class SoundFolder: CustomStringConvertible, Identifiable, Loggable, Equatable {
    typealias ID = String
    
    static let instance = SoundFolder.loadFromBundle()
    
    let id: String
    let url: URL?
    let displayName: String
    
    fileprivate(set) var sounds: [SoundFile]
    
    fileprivate(set) var subFolders: [SoundFolder]
    
    static let empty = SoundFolder()

    init(withID id: String,
         url: URL?,
         displayName: String,
         sounds: [SoundFile],
         subFolders: [SoundFolder]) {
        
        self.id = id
        self.url = url
        self.displayName = displayName
        self.sounds = sounds
        self.subFolders = subFolders
    }
    
    convenience init() {
        self.init(withID: "", url: nil, displayName: "", sounds: [], subFolders: [])
    }

    convenience init(withID id: String,
         url: URL?,
         displayName: String) {
    
        self.init(withID: id, url: url, displayName: displayName, sounds: [], subFolders: [])
    }

    var soundCount: Int {
        return self.sounds.count
    }
    
    var isEmpty: Bool {
        return self.soundCount == 0
    }

    lazy var allSounds: [SoundFile] = {
        
        var sounds: [SoundFile] = []
        
        self.sounds.forEach() { sounds.append($0) }
        
        self.subFolders.forEach() { sounds.append(contentsOf: $0.allSounds) }

        let sortedSounds = sounds.sorted { lhs, rhs in
            lhs.id.localizedCaseInsensitiveCompare(rhs.id) == ComparisonResult.orderedAscending
        }

        return sortedSounds
    }()

    func index(forSoundFileID id: String) -> Int? {
        if let index = self.sounds.firstIndex(where: { $0.id == id }) {
            return index
        }
        
        return nil
    }
    
    func addSound(_ soundFile: SoundFile) {
        self.sounds.append(soundFile)
    }

    func addSoundFolder(_ soundFolder: SoundFolder) {
        self.subFolders.append(soundFolder)
    }

    
    func addSounds(_ sounds: [SoundFile]) {
        sounds.forEach { self.addSound($0) }
    }
    
    func removeSound(_ soundFile: SoundFile) {
        if let index = index(forSoundFileID: soundFile.id) {
            self.sounds.remove(at: index)
        }
    }
    
    static func == (lhs: SoundFolder, rhs: SoundFolder) -> Bool {
        return lhs.id == rhs.id &&
            lhs.url == rhs.url &&
            lhs.displayName == rhs.displayName &&
            lhs.sounds == rhs.sounds &&
            lhs.subFolders == rhs.subFolders
    }

    var lengthyDescription: String {
        
        var allItems: [String] = []
        
        self.visitEach() { folder, sound, depth in
            
            if sound != nil {
                allItems.append(sound!.description.prepend(with: " ", count: depth * 4))
            } else {
                allItems.append(folder.description.prepend(with: " ", count: depth * 4))
            }
        }
        
        let allItemsString = allItems.joined(separator: "\n")
        
        return "\(type(of:self)): \(self.url?.path ?? "nil"):\n\(allItemsString)"
    }
    
    var description: String {
        return "\(type(of:self)): id: \(self.id), displayName: \(self.displayName), url: \(String(describing:self.url)), soundCount: \(self.sounds.count), subFolders:\(self.subFolders.count)"
    }
}

extension SoundFolder {
    typealias Visitor = (_ soundFolder: SoundFolder, _ soundFile: SoundFile?, _ depth: Int) -> Void
    
    private func visitEach(depth: Int,
                           visitor: Visitor) {
        
        self.sounds.forEach {
            visitor(self, $0, depth)
        }
        
        self.subFolders.forEach {
            visitor($0, nil, depth)
            $0.visitEach(depth: depth + 1, visitor:visitor)
        }
    }
    
    func visitEach(_ visitor: Visitor) {
        visitor(self, nil, 0)
        self.visitEach(depth: 1, visitor: visitor)
    }
}


// searching
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
    
    func findSounds(containingNames containing: [String],
                    excluding exactExclusions: [String] = []) -> [SoundFile]? {
        
        var sounds:[SoundFile] = []
        for sound in self.allSounds {
            containing.forEach {
                if sound.displayName.localizedCaseInsensitiveContains($0) &&
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
    
    func findFolder(containing name: String, parent: SoundFolder?) -> SoundFolder? {
    
        let outFolder = SoundFolder(withID: UUID().uuidString, url: nil, displayName: "Search")
        
        if parent != nil && outFolder.displayName.localizedCaseInsensitiveContains(name) {
            outFolder.sounds = self.sounds
            outFolder.subFolders = self.subFolders
            return outFolder
        }
        
        var sounds:[SoundFile] = []
        
        for sound in self.sounds {
            if sound.displayName.localizedCaseInsensitiveContains(name) {
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

// loading
extension SoundFolder {
    
    static func loadFromBundle() -> SoundFolder {
        if  let resourcePath = Bundle.main.resourceURL {
            let soundPath = resourcePath.appendingPathComponent("Sounds")
            
            do {
                let directory = try DirectoryIterator(withURL: soundPath)
                return SoundFolder(withDirectory: directory)
            } catch {
                self.logger.error("Creating SoundFolder failed with error: \(error.localizedDescription)")
            }
        }
        
        return SoundFolder.empty
    }

    private static func cleanupName(_ url: URL?) -> String {
        if let theURL = url {
            return theURL.deletingPathExtension().path.replacingOccurrences(of: "-", with: " ").replacingOccurrences(of: "_", with: " ")
        }
        
        return ""
    }
    
    convenience init(withDirectory directory: DirectoryIterator) {
        
        self.init(withID: UUID().uuidString,
                  url: directory.url,
                  displayName: Self.cleanupName(directory.url))
        
        for file in directory.files {
            if let url = file.url {
                self.addSound(SoundFile(withID:UUID().uuidString,
                                        url: url,
                                        displayName: Self.cleanupName(url),
                                        randomizer: SoundSetRandomizer.none))
            }
        }

        for directory in directory.directories {
            self.addSoundFolder(SoundFolder(withDirectory: directory))
        }
    }
    
}

extension SoundFolder {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case url = "url"
        case displayName = "displayName"
        case sounds = "sounds"
        case folders = "subFolders"
    }
    
    convenience init?(withDictionary dictionaryOrNil: [AnyHashable : Any]?) {

        if let dictionary = dictionaryOrNil,
           let id = dictionary[CodingKeys.id.rawValue] as? String,
           let url = dictionary[CodingKeys.url.rawValue] as? String,
           let displayName = dictionary[CodingKeys.displayName.rawValue] as? String,
           let sounds = dictionary[CodingKeys.displayName.rawValue] as? [[AnyHashable: Any]],
           let subFolders = dictionary[CodingKeys.displayName.rawValue] as? [[AnyHashable: Any]] {
            
            self.init(withID: id,
                      url: URL(fileURLWithPath: url),
                      displayName: displayName)
            
            
            sounds.forEach {
                if let soundFile = SoundFile(withDictionary: $0) {
                    self.addSound(soundFile)
                }
            }
            
            subFolders.forEach {
                if let folder = SoundFolder(withDictionary: $0) {
                    self.addSoundFolder(folder)
                }
            }
        } else {
            return nil
        }
    }

    var asDictionary: [AnyHashable : Any] {
        var dictionary: [AnyHashable : Any] = [:]
        dictionary[CodingKeys.id.rawValue] = self.id
        dictionary[CodingKeys.url.rawValue] = self.url?.path ?? ""
        dictionary[CodingKeys.displayName.rawValue] = self.displayName
        dictionary[CodingKeys.sounds.rawValue] = self.sounds.map { $0.asDictionary }
        dictionary[CodingKeys.folders.rawValue] = self.subFolders.map { $0.asDictionary }
        return dictionary
    }
}
