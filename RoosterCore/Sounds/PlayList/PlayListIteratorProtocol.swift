//
//  SoundSetIterator.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/5/21.
//

import Foundation

// public enum PlayListIteratorState {
//    case idle, iterating, done
// }

public protocol PlayListIteratorProtocol: CustomStringConvertible {
    var isRandom: Bool { get }

    var isEmpty: Bool { get }

    var current: SoundPlayer? { get }

    func start()

    func next()

    func stop()

    var isDone: Bool { get }

    var soundPlayers: [SoundPlayer] { get }
}

// extension PlayListIteratorProtocol {
//    
//    public func soundPlayer(forIdentifier identifier: String) -> SoundPlayer? {
//        for sound in self.sounds {
//            if sound.id == identifier {
//                return sound
//            }
//        }
//        
//        return nil
//    }
//    
//    
// }
