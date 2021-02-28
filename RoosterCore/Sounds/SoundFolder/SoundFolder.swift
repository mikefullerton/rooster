//
//  SoundResources.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/10/21.
//

import Foundation


public class SoundFolder: SoundFolderItem, Codable {

    fileprivate(set) public var soundFiles: [SoundFile] {
        didSet {
            self.cachedAllSounds = nil
        }
    }
    
    private(set) public var subFolders: [SoundFolder] {
        didSet {
            self.cachedAllSounds = nil
        }
    }
    
    public var directoryName: String {
        return self.relativePath.lastPathComponent
    }
    
    private var cachedAllSounds: [SoundFile]? = nil
    
    public static let empty = SoundFolder()

    public convenience init(withID id: String,
                            directoryPath: URL,
                            displayName: String) {
    
        self.init(withID: id,
                  directoryPath: directoryPath,
                  directoryName: directoryPath.lastPathComponent,
                  displayName: displayName,
                  soundFiles: [],
                  subFolders: [])
    }

    public convenience init(withID id: String,
                            directoryName: String,
                            displayName: String) {
    
        self.init(withID: id,
                  directoryPath: URL.empty,
                  directoryName: displayName,
                  displayName: displayName,
                  soundFiles: [],
                  subFolders: [])
    }

    
    fileprivate init(withID id: String,
                     directoryPath: URL?,
                     directoryName: String,
                     displayName: String,
                     soundFiles: [SoundFile],
                     subFolders: [SoundFolder]) {

        self.soundFiles = []
        self.subFolders = []

        super.init(withID: id, displayName: displayName)
        
        self.relativePath = URL(withRelativePath: directoryName)
        self.absolutePath = directoryPath
        self.setSoundFiles(soundFiles)
        self.setSubFolders(subFolders)
    }

    public convenience init(withID id: String,
                            directoryName: String,
                            displayName: String,
                            sounds: [SoundFile],
                            subFolders: [SoundFolder]) {
    
        self.init(withID: id,
                  directoryName: directoryName,
                  displayName: displayName)
        
        self.setSoundFiles(sounds)
        self.setSubFolders(subFolders)
    }

    public convenience init() {
        self.init(withID: "",
                  directoryName: "",
                  displayName: "")
    }

    public var soundCount: Int {
        return self.soundFiles.count
    }
    
    public var subFolderCount: Int {
        return self.subFolders.count
    }
    
    public var itemCount: Int {
        return self.soundCount + self.subFolderCount
    }
    
    public var isEmpty: Bool {
        return self.itemCount == 0
    }
    
    public var randomSoundFile: SoundFile {
        return self.allSoundFiles.randomElement() ?? SoundFile.empty
    }

    public var allSoundFiles: [SoundFile] {
        
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

    public func index(forSoundFileID id: String) -> Int? {
        if let index = self.soundFiles.firstIndex(where: { $0.id == id }) {
            return index
        }
        
        return nil
    }

    public func index(forSubFolderID id: String) -> Int? {
        if let index = self.subFolders.firstIndex(where: { $0.id == id }) {
            return index
        }
        
        return nil
    }

    // MARK: -
    // MARK: Sounds
    
    public func addSoundFile(_ soundFile: SoundFile) {
        if let newSound = soundFile.copy() as? SoundFile {
            newSound.setParent(self)
            self.soundFiles.append(newSound)
        }
    }

    public func addSoundFiles(_ sounds: [SoundFile]) {
        sounds.forEach { self.addSoundFile($0) }
    }
    
    public func removeSoundFile(forID id: String) {
        if let index = index(forSoundFileID: id) {
            self.soundFiles[index].setParent(nil)
            self.soundFiles.remove(at: index)
        }
    }

    public func setSoundFiles(_ sounds: [SoundFile]) {
        self.removeAllSoundFiles()
        self.addSoundFiles(sounds)
    }
    
    public func removeAllSoundFiles() {
        self.soundFiles.forEach { $0.setParent(nil) }
        self.soundFiles = []
    }
    
    // MARK: -
    // MARK: Subfolders
    
    public func addSubFolder(_ soundFolder: SoundFolder) {
        if let newFolder = soundFolder.copy() as? SoundFolder {
            newFolder.setParent(self)
            self.subFolders.append(newFolder)
        }
    }
    
    public func removeSubFolder(forID id: String) {
        if let index = index(forSubFolderID: id) {
            self.subFolders[index].setParent(nil)
            self.subFolders.remove(at: index)
        }
    }
    
    public func addSubFolders(_ soundFolders: [SoundFolder]) {
        soundFolders.forEach { self.addSubFolder($0) }
    }

    public func removeAllSubFolders() {
        self.subFolders.forEach { $0.setParent(nil) }
        self.subFolders = []
    }

    public func setSubFolders(_ subFolders: [SoundFolder]) {
        self.removeAllSubFolders()
        self.addSubFolders(subFolders)
    }
    
    // MARK: -
    // MARK: Misc
    
    public func removeAll() {
        self.removeAllSoundFiles()
        self.removeAllSubFolders()
    }

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case absolutePath = "absolutePath"
        case relativePath = "relativePath"
        case displayName = "displayName"
        case soundFiles = "soundFiles"
        case subFolders = "subFolders"
    }
    
    public required init(from decoder: Decoder) throws {
        self.soundFiles = []
        self.subFolders = []

        super.init(withID: "", displayName: "")
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try self.id = values.decode(String.self, forKey: .id)
        try self.displayName = values.decode(String.self, forKey: .displayName)
        try self.absolutePath = values.decode(URL.self, forKey: .absolutePath)
        try self.relativePath = values.decode(URL.self, forKey: .relativePath)
        try self.soundFiles = values.decode([SoundFile].self, forKey: .soundFiles)
        try self.subFolders = values.decode([SoundFolder].self, forKey: .subFolders)

        if self.id == Self.defaultSoundFolderID {
            let defaultFolder = Self.instance
            self.absolutePath = defaultFolder.absolutePath
            self.soundFiles = defaultFolder.soundFiles
            self.subFolders = defaultFolder.subFolders
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.displayName, forKey: .displayName)
        
        try container.encode(self.absolutePath, forKey: .absolutePath)
        try container.encode(self.relativePath, forKey: .relativePath)
        
        if self.isDefaultSoundFolder {
            try container.encode([] as [SoundFile], forKey: .soundFiles)
            try container.encode([] as [SoundFolder], forKey: .subFolders)
        } else {
            try container.encode(self.soundFiles, forKey: .soundFiles)
            try container.encode(self.subFolders, forKey: .subFolders)
        }
    }
    
    private func updateChildrensRelativePaths() {
        self.subFolders.forEach { $0.updateRelativePath() }
        self.soundFiles.forEach { $0.updateRelativePath() }
    }
    
    override func didSetRelativePath() {
        self.updateChildrensRelativePaths()
    }
    
    public override func updateRelativePath() {
        self.relativePath = self.relativePathFromRootFolder

        if  self.parent != nil,
            let rootFolderPath = self.rootFolder?.absolutePath {
            
            self.absolutePath = rootFolderPath.appendingPathComponent(self.relativePath.path)
        }
    }

    public override var description: String {
        return """
            \(type(of:self)): \
            id: \(self.id), \
            displayName: \(self.displayName), \
            directoryName: \(self.directoryName), \
            absolutePath: \(self.absolutePath?.path ?? "nil"), \
            relativePath: \(self.relativePath.path), \
            soundCount: \(self.soundFiles.count), \
            subFoldersCount:\(self.subFolders.count), \
            parent: \(self.parent?.description ?? "nil")"
            """
    }

    public convenience init(withDescriptor descriptor: SoundFolderDescriptor,
                            atPath url: URL) {
        
        self.init(withID: descriptor.metadata.id,
                  directoryPath: url,
                  displayName: descriptor.metadata.displayName)
    }
    

}

//
//extension SoundFile {
////    fileprivate
//
//    // TODO: fix this
//    public func setParent(_ soundFolder: SoundFolder?) {
//        self.parent = soundFolder
//    }
//}
//
//extension SoundFolder {
////    internal
//    // TODO: fix this
//
//    public func setParent(_ soundFolder: SoundFolder?) {
//        self.parent = soundFolder
//    }
//
//}

extension SoundFolder: NSCopying {
    public func copy(with zone: NSZone? = nil) -> Any {
        return SoundFolder(withID: self.id,
                           directoryPath: self.absolutePath,
                           directoryName: self.directoryName,
                           displayName: self.displayName,
                           soundFiles: self.soundFiles.map { $0.copy() as! SoundFile },
                           subFolders: self.subFolders.map { $0.copy() as! SoundFolder })
    }
}

extension SoundFolder: Equatable {
    public static func == (lhs: SoundFolder, rhs: SoundFolder) -> Bool {
        return lhs.id == rhs.id &&
            lhs.absolutePath == rhs.absolutePath &&
            lhs.relativePath == rhs.relativePath &&
            lhs.displayName == rhs.displayName &&
            lhs.soundFiles == rhs.soundFiles &&
            lhs.subFolders == rhs.subFolders
    }
}

extension SoundFolder: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        
        var allItems: [String] = []
        
        self.visitEach { item in
            allItems.append(item.description.prepend(with: " ", count: item.parents.count * 4))
        }
        
        let allItemsString = allItems.joined(separator: "\n")
        
        return "\(self.description):\n\(allItemsString)"
    }
}

