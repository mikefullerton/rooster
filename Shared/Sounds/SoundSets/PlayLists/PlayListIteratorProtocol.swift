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
    
    var sounds: [SoundFile] { get }
    
    var state: PlayListIteratorState { get }
    
    func step() -> SoundFile?
    
    func stop()
    
    func resetToIdleState()
}
