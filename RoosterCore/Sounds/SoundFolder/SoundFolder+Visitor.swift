//
//  SoundFolder+Visitor.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/11/21.
//

import Foundation

extension SoundFolder {
    public typealias Visitor = (_ item: SoundFolderItem) -> Void
    
    public func visitEach(_ visitor: Visitor) {
        visitor(self)
        
        self.soundFiles.forEach { soundFile in
            visitor(soundFile)
        }
        
        self.subFolders.forEach { subfolder in
            subfolder.visitEach(visitor)
        }
    }
}
