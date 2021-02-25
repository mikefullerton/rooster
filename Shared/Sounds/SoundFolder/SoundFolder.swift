//
//  SoundResources.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/10/21.
//

import Foundation


class SoundFolder: Identifiable, Loggable, SoundFolderItem, Codable {
    typealias ID = String
    
    static let instance = SoundFolder.loadFromBundle()
    
    var id: String
    private(set) var url: URL
    var displayName: String
    
    fileprivate(set) weak var parent: SoundFolder? {
        didSet {
            self.updateURLForNewParent()
        }
    }
    
    fileprivate(set) var soundFiles: [SoundFile] {
        didSet {
            self.cachedAllSounds = nil
        }
    }
    
    private(set) var subFolders: [SoundFolder] {
        didSet {
            self.cachedAllSounds = nil
        }
    }
    
    private var cachedAllSounds: [SoundFile]? = nil
    
    static let empty = SoundFolder()

    init(withID id: String,
         url: URL,
         displayName: String) {
    
        self.id = id
        self.url = url
        self.displayName = displayName
        self.soundFiles = []
        self.subFolders = []
    }

    convenience init(withID id: String,
                     url: URL,
                     displayName: String,
                     sounds: [SoundFile],
                     subFolders: [SoundFolder]) {
    
        self.init(withID: id,
                  url: url,
                  displayName: displayName) 
        self.setSoundFiles(sounds)
        self.setSubFolders(subFolders)
    }

    convenience init() {
        self.init(withID: "",
                  url: URL.emptyRoosterURL,
                  displayName: "")
    }

    var soundCount: Int {
        return self.soundFiles.count
    }
    
    var subFolderCount: Int {
        return self.subFolders.count
    }
    
    var itemCount: Int {
        return self.soundCount + self.subFolderCount
    }
    
    var isEmpty: Bool {
        return self.itemCount == 0
    }

    var allSoundFiles: [SoundFile] {
        
        if let allSounds = cachedAllSounds {
            return allSounds
        }
        
        var allSounds: [SoundFile] = []
        
        self.soundFiles.forEach() {
            allSounds.append($0)
        }
        
        self.subFolders.forEach() {
            allSounds.append(contentsOf: $0.allSoundFiles)
        }

        let sortedAllSounds = allSounds.sorted { lhs, rhs in
            lhs.id.localizedCaseInsensitiveCompare(rhs.id) == ComparisonResult.orderedAscending
        }

        self.cachedAllSounds = sortedAllSounds
        
        return sortedAllSounds
    }

    func index(forSoundFileID id: String) -> Int? {
        if let index = self.soundFiles.firstIndex(where: { $0.id == id }) {
            return index
        }
        
        return nil
    }

    func index(forSubFolderID id: String) -> Int? {
        if let index = self.subFolders.firstIndex(where: { $0.id == id }) {
            return index
        }
        
        return nil
    }

    // MARK: -
    // MARK: Sounds
    
    func addSoundFile(_ soundFile: SoundFile) {
        if let newSound = soundFile.copy() as? SoundFile {
            newSound.setParent(self)
            self.soundFiles.append(newSound)
        }
    }

    func addSoundFiles(_ sounds: [SoundFile]) {
        sounds.forEach { self.addSoundFile($0) }
    }
    
    func removeSoundFile(forID id: String) {
        if let index = index(forSoundFileID: id) {
            self.soundFiles[index].setParent(nil)
            self.soundFiles.remove(at: index)
        }
    }

    func setSoundFiles(_ sounds: [SoundFile]) {
        self.removeAllSoundFiles()
        self.addSoundFiles(sounds)
    }
    
    func removeAllSoundFiles() {
        self.soundFiles.forEach { $0.setParent(nil) }
        self.soundFiles = []
    }
    
    // MARK: -
    // MARK: Subfolders
    
    func addSubFolder(_ soundFolder: SoundFolder) {
        if let newFolder = soundFolder.copy() as? SoundFolder {
            newFolder.setParent(self)
            self.subFolders.append(newFolder)
        }
    }
    
    func removeSubFolder(forID id: String) {
        if let index = index(forSubFolderID: id) {
            self.subFolders[index].setParent(nil)
            self.subFolders.remove(at: index)
        }
    }
    
    func addSubFolders(_ soundFolders: [SoundFolder]) {
        soundFolders.forEach { self.addSubFolder($0) }
    }

    func removeAllSubFolders() {
        self.subFolders.forEach { $0.setParent(nil) }
        self.subFolders = []
    }

    func setSubFolders(_ subFolders: [SoundFolder]) {
        self.removeAllSubFolders()
        self.addSubFolders(subFolders)
    }
    
    // MARK: -
    // MARK: Misc
    
    func removeAll() {
        self.removeAllSoundFiles()
        self.removeAllSubFolders()
    }

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case url = "url"
        case displayName = "displayName"
        case soundFiles = "soundFiles"
        case subFolders = "subFolders"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try self.id = values.decode(String.self, forKey: .id)
        try self.displayName = values.decode(String.self, forKey: .displayName)
        try self.url = values.decode(URL.self, forKey: .url)
        try self.soundFiles = values.decode([SoundFile].self, forKey: .soundFiles)
        try self.subFolders = values.decode([SoundFolder].self, forKey: .subFolders)

        if self.id == Self.defaultSoundFolderID {
            let defaultFolder = Self.instance
            self.url = defaultFolder.url
            self.soundFiles = defaultFolder.soundFiles
            self.subFolders = defaultFolder.subFolders
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.displayName, forKey: .displayName)
        try container.encode(self.url, forKey: .url)
        if self.isDefaultSoundFolder {
            try container.encode([] as [SoundFile], forKey: .soundFiles)
            try container.encode([] as [SoundFolder], forKey: .subFolders)
        } else {
            try container.encode(self.soundFiles, forKey: .soundFiles)
            try container.encode(self.subFolders, forKey: .subFolders)
        }
    }
    
    func updateURLForNewParent() {
        self.url = self.updatedURL
        
        self.subFolders.forEach { $0.updateURLForNewParent() }
    }

    var updatedURL: URL {
        if let parent = self.parent {
            return parent.url.appendingPathComponent(self.url.lastPathComponent)
        }
        
        return self.url
    }
}


extension SoundFile {
    fileprivate func setParent(_ soundFolder: SoundFolder?) {
        self.parent = soundFolder
    }
}

extension SoundFolder {
    internal func setParent(_ soundFolder: SoundFolder?) {
        self.parent = soundFolder
    }

}


