//
//  RandomSoundFile.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/1/21.
//

import Foundation

public class RandomSoundFile: SoundFile {
    private(set) var actualSoundFile: SoundFile

    override public var underlyingSoundFile: SoundFile {
        self.actualSoundFile
    }

    override public var isRandom: Bool {
        true
    }

    // swiftlint:disable unused_setter_value

    // private(set) 
    override public var relativePath: URL {
        get { self.actualSoundFile.relativePath }
        set(path) {
        }
    }

    override public var absolutePath: URL? {
        get {
            self.actualSoundFile.absolutePath
        }
        set(path) {
        }
    }
    // swiftlint:enable unused_setter_value

    override public weak var parent: SoundFolder? {
        get { super.parent }
        set(parent) {
            super.parent = parent
            self.updateActualSoundFile()
        }
    }

    public init() {
        self.actualSoundFile = SoundFile.empty
        super.init(withID: Self.randomSoundID, fileName: "Random", displayName: "Random")
    }

    @available(*, unavailable)
    public required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }

    var randomSound: SoundFile {
        if let parent = self.parent {
            return parent.allSoundFiles.randomElement()!
        }

        return SoundFile.empty
    }

    func updateActualSoundFile() {
        self.actualSoundFile = self.randomSound
    }

    override public func copy(with zone: NSZone? = nil) -> Any {
        let randomSoundFile = RandomSoundFile()
        randomSoundFile.setParent(self.parent)
        return randomSoundFile
    }

    override public var description: String {
        """
        \(super.description): \
        Actual Sound File: \(self.actualSoundFile.description)
        """
    }

    override func nativeSoundDidStop() {
        self.updateActualSoundFile()
    }

    override public var displayNameWithParentsExcludingRoot: String {
        self.actualSoundFile.displayNameWithParentsExcludingRoot
    }

    override public var displayNameWithParents: String {
        self.actualSoundFile.displayNameWithParents
    }

    override public var pathComponents: [SoundFolderItem] {
        self.actualSoundFile.pathComponents
    }
}
