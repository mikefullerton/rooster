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
        return self.actualSoundFile
    }
    
    public override var isRandom: Bool {
        return true
    }
    
    //private(set) 
    public override var relativePath: URL {
        get { return self.actualSoundFile.relativePath }
        set(path) {
            
        }
    }
    
    public override var absolutePath: URL? {
        get {
            return self.actualSoundFile.absolutePath
        }
        set(path) {
            
        }
    }
    
    public override weak var parent: SoundFolder? {
        get { return super.parent }
        set(parent) {
            super.parent = parent
            self.updateActualSoundFile()
        }
    }
  
    public init() {
        self.actualSoundFile = SoundFile.empty
        super.init(withID: Self.randomSoundID, fileName: "Random", displayName: "Random")
    }
    
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
    
    public override func copy(with zone: NSZone? = nil) -> Any {
        let randomSoundFile = RandomSoundFile()
        randomSoundFile.setParent(self.parent)
        return randomSoundFile
    }

    public override var description: String {
        return """
        \(super.description): \
        Actual Sound File: \(self.actualSoundFile.description)
        """
    }
    
    override func nativeSoundDidStop() {
        self.updateActualSoundFile()
    }
    
    public override var displayNameWithParentsExcludingRoot: String {
        return self.actualSoundFile.displayNameWithParentsExcludingRoot
    }
    
    public override var displayNameWithParents: String {
        return self.actualSoundFile.displayNameWithParents
    }
    
    public override var pathComponents: [SoundFolderItem] {
        return self.actualSoundFile.pathComponents
    }

}

