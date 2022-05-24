//
//  SoundFile.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/3/21.
//

import Foundation

public class SoundFile: SoundFolderItem, Codable, Equatable, NSCopying {
    public let fileName: String

    public static let empty = SoundFile()

    public lazy var soundPlayer: SoundPlayerProtocol = NativeSoundPlayer(withSoundFile: self)

    public var underlyingSoundFile: SoundFile {
        self
    }

    override public func didSetRelativePath() {
        print("New SoundFile relative path: \(self.relativePath.path)")
    }

    override public var absolutePath: URL? {
        get {
            if let rootFolderPath = self.rootFolder?.absolutePath {
                let outPath = rootFolderPath.deletingLastPathComponent().appendingPathComponent(self.relativePath.path)
                self.logger.log("sound file path: \(outPath)")
                return outPath
            }

            return nil
        }
        set {
        }
    }
    // swiftlint:enable unused_setter_value

    public convenience init() {
        self.init(withID: "",
                  fileName: "",
                  displayName: "")
    }

    public init(withID id: String,
                fileName: String,
                displayName: String) {
        self.fileName = fileName
        super.init(withID: id, displayName: displayName)
        self.relativePath = URL(withRelativePath: fileName)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case fileName
        case displayName
        case relativePath
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try self.fileName = values.decode(String.self, forKey: .fileName)

        super.init(withID: "", displayName: "")

        self.id = try values.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.displayName = try values.decodeIfPresent(String.self, forKey: .displayName) ?? ""
        self.relativePath = try values.decodeIfPresent(URL.self, forKey: .relativePath) ?? URL.empty
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.displayName, forKey: .displayName)
        try container.encode(self.fileName, forKey: .fileName)
        try container.encode(self.relativePath.path, forKey: .relativePath)
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        SoundFile(withID: self.id, fileName: self.fileName, displayName: self.displayName)
    }

    override public var description: String {
        """
        \(type(of: self)): \
        id: \(self.id), \
        displayName: \(self.displayName), \
        fileName: \(self.fileName), \
        relativePath: \(self.relativePath.path), \
        absolutePath: \(self.absolutePath?.path ?? "nil")"
        """
    }

    public static func == (lhs: SoundFile, rhs: SoundFile) -> Bool {
        lhs.id == rhs.id &&
                lhs.displayName == rhs.displayName &&
                lhs.fileName == rhs.fileName &&
                lhs.relativePath == rhs.relativePath &&
                lhs.absolutePath == rhs.absolutePath
    }

    override public func updateRelativePath() {
        self.relativePath = self.relativePathFromRootFolder

        self.logger.debug("New url for \(self.description)")
    }

    public convenience init(withDescriptor descriptor: SoundFileDescriptor, atPath url: URL) {
        self.init(withID: descriptor.metadata.id,
                  fileName: url.lastPathComponent,
                  displayName: descriptor.metadata.displayName)
    }

//    public static let randomSoundID = "0d67e781-826a-4c4f-807c-0dbe6514da3e"
// 
//    public static let random = SoundFile(withID: SoundFile.randomSoundID, fileName: "", displayName: "")
//    
//    public var isRandom: Bool {
//        return self.id == Self.randomSoundID
//    }
}
