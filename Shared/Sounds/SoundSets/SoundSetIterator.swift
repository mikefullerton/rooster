//
//  SoundSetIterator.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/5/21.
//

import Foundation

protocol SoundSetIterator {
    
    var currentSound: SoundFile? { get }
    
    // peek at next sound
    var nextSound: SoundFile? { get }
    
    var currentOrFirstSound: SoundFile? { get }
    
    var sounds: [SoundFile] { get }
    
    var hasFinished: Bool { get }
    
    var displayName: String { get }
    
    var isEmpty: Bool { get }
    
    func advanceForward() -> SoundFile?
}

class SingleSoundSetIterator : SoundSetIterator {
    let soundSet:SoundSet
    
    private var playList:[SoundFile]
    private var index: Int?
    
    init(withSoundSet soundSet: SoundSet) {
        self.soundSet = soundSet
        self.index = nil
        self.playList = []
        self.constructPlaylist()
    }
    
    private func constructPlaylist() {
        var random:[SoundFileDescriptor] = []
    
        let descriptors = self.soundSet.soundFileDescriptors
        
        descriptors.forEach { (soundIdentifier) in
            if soundIdentifier.randomizerPriority == .normal {
                random.append(soundIdentifier)
            }

            if soundIdentifier.randomizerPriority == .high {
                random.append(soundIdentifier)
                random.append(soundIdentifier)
            }
        }
        
        descriptors.forEach { (soundIdentifier) in
            var newSoundIdentifier = soundIdentifier
            
            if soundIdentifier.randomizerPriority != .never,
               let random = random.randomElement() {
                newSoundIdentifier = random
            }
            
            if let soundFile = SoundFolder.instance.findSound(forIdentifier: newSoundIdentifier.id) {
                self.playList.append(soundFile)
            }
        }
    }
    
    var hasFinished: Bool {
        return self.index == nil
    }
    
    var currentSound: SoundFile? {
        if let index = self.index {
            return self.sounds[index]
        }
        
        return nil
    }
    
    private var nextIndex: Int? {
        if let index = self.index {
            if index + 1 < self.sounds.count {
                return index + 1
            }
            
            return nil
        }
       
        if self.sounds.count > 0 {
            return 0
        }
        
        return nil
    }
    
    func advanceForward() -> SoundFile? {
        self.index = self.nextIndex
        return self.currentSound
    }
    
    var nextSound: SoundFile? {
        if let index = self.nextIndex {
            return self.sounds[index]
        }
            
        return nil
    }
    
    var sounds: [SoundFile] {
        return self.soundSet.sounds
    }
    
    var currentOrFirstSound: SoundFile? {
        if let currentSound = self.currentSound {
            return currentSound
        }
        
        if self.playList.count > 0 {
            return self.playList[0]
        }
        
        return nil
    }
    
    var displayName: String {
        if let currentOrFirstSound = self.currentOrFirstSound {
            return "\(currentOrFirstSound.displayName) (\(self.soundSet.name))"
        }
        
        return "NONE".localized
    }
    
    var isEmpty: Bool {
        return self.playList.count == 0
    }
}

