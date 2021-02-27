//
//  SingleSoundSetIterator.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/11/21.
//

import Foundation

public class PlayListIterator : PlayListIteratorProtocol, Loggable {

    // what's left to play, in order
    private(set) public var playList: [SoundPlayer]
    
    // the original playlist (which can possibly change at the start of each iteration)
    private(set) public var sounds: [SoundPlayer]
    
    private(set) public var state: PlayListIteratorState

    private let randomizer: PlayListRandomizer
    private let originalSounds: [SoundPlayer]

    public init(withSoundPlayers soundPlayers: [SoundPlayer],
         randomizer: PlayListRandomizer) {
        
        self.randomizer = randomizer
        self.state = .idle
        self.originalSounds = soundPlayers
        
        self.playList = []
        self.sounds = []
        
        self.updatePlaylist()
    }
    
    private func updatePlaylist() {
        let playList = PlayListGenerator().generate(withSounds: self.originalSounds, playListRandomizer: randomizer)
        self.playList = playList
        self.sounds = playList
    }
    
    public func stop() {
        if self.state == .iterating {
            self.updatePlaylist()
            self.state = .done
        }
    }
    
    public func step() -> SoundPlayer? {
        
        switch(self.state) {
        case .idle:
            self.state = .iterating
            
        case .done:
            self.state = .idle
            
        case .iterating:
            break
        }
        
        if self.state == .iterating {
            if let sound = self.removeSoundFromPlayList() {
                if self.playList.count == 0 {
                    self.stop()
                }
                return sound
            }
            
            self.stop()
        }

        return nil
    }
    
    public func resetToIdleState() {
        self.stop()
        self.state = .idle
    }
    
    private func removeSoundFromPlayList() -> SoundPlayer? {
        if self.playList.count > 0 {
            let sound = self.playList.first
            self.playList.remove(at: 0)
            return sound
        }
        return nil
    }
}


