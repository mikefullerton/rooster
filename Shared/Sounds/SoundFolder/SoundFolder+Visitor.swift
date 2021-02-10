//
//  SoundFolder+Visitor.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/11/21.
//

import Foundation

extension SoundFolder {
    typealias Visitor = (_ item: SoundFolderItem) -> Void
    
    func visitEach(_ visitor: Visitor) {
        visitor(self)
        
        self.sounds.forEach { soundFile in
            visitor(soundFile)
        }
        
        self.subFolders.forEach { subfolder in
            subfolder.visitEach(visitor)
        }
    }
}
