//
//  SoundSetIterator.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/5/21.
//

import Foundation

enum PlayListIteratorState {
    case idle, iterating, done
}

protocol PlayListIteratorProtocol {
    
    var sounds: [SoundFileSoundPlayer] { get }
    
    var state: PlayListIteratorState { get }
    
    func step() -> SoundFileSoundPlayer?
    
    func stop()
    
    func resetToIdleState()
}

extension PlayListIteratorProtocol {
    
    func soundPlayer(forIdentifier identifier: String) -> SoundFileSoundPlayer? {
        for sound in self.sounds {
            if sound.id == identifier {
                return sound
            }
        }
        
        return nil
    }
    
    
}
