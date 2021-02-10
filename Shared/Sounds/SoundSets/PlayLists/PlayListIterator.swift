//
//  SingleSoundSetIterator.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/11/21.
//

import Foundation


class PlayListIterator : PlayListIteratorProtocol, Loggable {

    // what's left to play, in order
    private(set) var playList: [SoundFile]
    
    // the original playlist (which can possibly change at the start of each iteration)
    private(set) var sounds: [SoundFile]
    
    private(set) var state: PlayListIteratorState

    private let randomizer: RandomizationDescriptor
    private let originalSounds: [SoundFile]

    init(withSounds sounds: [SoundFile],
         randomizer: RandomizationDescriptor) {
        
        self.randomizer = randomizer
        self.state = .idle
        self.originalSounds = sounds
        
        let playList = SoundPlayListGenerator.generate(withSounds: sounds, randomizer: randomizer)
        
        self.playList = playList
        self.sounds = playList
    }
    
    func stop() {
        if self.state == .iterating {
            self.playList = SoundPlayListGenerator.generate(withSounds: self.sounds, randomizer: self.randomizer)
            self.sounds = self.playList
            self.state = .done
        }
    }
    
    func step() -> SoundFile? {
        
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
    
    func resetToIdleState() {
        self.stop()
        self.state = .idle
    }
    
    private func removeSoundFromPlayList() -> SoundFile? {
        if self.playList.count > 0 {
            let sound = self.playList.first
            self.playList.remove(at: 0)
            return sound
        }
        return nil
    }
}


