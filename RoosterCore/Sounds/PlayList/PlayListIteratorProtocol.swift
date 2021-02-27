//
//  SoundSetIterator.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/5/21.
//

import Foundation

public enum PlayListIteratorState {
    case idle, iterating, done
}

public protocol PlayListIteratorProtocol {
    
    var sounds: [SoundPlayer] { get }
    
    var state: PlayListIteratorState { get }
    
    func step() -> SoundPlayer?
    
    func stop()
    
    func resetToIdleState()
}

extension PlayListIteratorProtocol {
    
    public func soundPlayer(forIdentifier identifier: String) -> SoundPlayer? {
        for sound in self.sounds {
            if sound.id == identifier {
                return sound
            }
        }
        
        return nil
    }
    
    
}
