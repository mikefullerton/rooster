//
//  MultipleSoundSetIterator.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/6/21.
//

import Foundation

class MultipleSoundSetIterator : SoundSetIterator {
    
    private let iterators:[SoundSetIterator]
    private var index: Int?
    
    init(withSoundSet soundSets: [SoundSet]) {
        self.iterators = soundSets.map { SingleSoundSetIterator(withSoundSet: $0) }
        self.index = nil
    }

    private func findNextIteratorIndex(startAt startIndex: Int?) -> Int? {
        
        if let index = startIndex {
            var walker = index
            while walker >= 0 && walker + 1 < self.iterators.count {
                let iterator = self.iterators[walker]
                if let _ = iterator.nextSound {
                    return walker
                }
                walker += 1
            }
        }
        
        return nil
    }

    var hasFinished: Bool {
        return self.index == nil
    }
    
    private var currentIterator: SoundSetIterator? {
        if let index = self.index {
            return self.iterators[index]
        }
        
        return nil
    }
    
    private var currentOrFirstIterator: SoundSetIterator? {
        if let current = self.currentIterator {
            return current
        }
        
        if self.iterators.count > 0 {
            return self.iterators[0]
        }
        
        return nil
    }
    
    var currentOrFirstSound: SoundFile? {
        return self.currentOrFirstIterator?.currentOrFirstSound
    }
    
    private var nextIterator: SoundSetIterator? {
        if let index = self.findNextIteratorIndex(startAt: self.index) {
            return self.iterators[index]
        }
            
        return nil
    }
    
    var currentSound: SoundFile? {
        return self.currentIterator?.currentSound
    }
    
    var nextSound: SoundFile? {
        return self.nextIterator?.nextSound
    }

    func advanceForward() -> SoundFile? {
        if let index = self.index {
            self.index = self.findNextIteratorIndex(startAt: index)
            return self.currentIterator?.advanceForward() ?? nil
        } else if self.iterators.count > 0 {
            self.index = 0
            return self.currentIterator?.advanceForward() ?? nil
        }
        
        return nil
    }
    
    var sounds: [SoundFile] {
        var sounds:[SoundFile] = []
        self.iterators.forEach { sounds.append(contentsOf: $0.sounds) }
        return sounds
    }

    var displayName: String {
        return self.currentOrFirstSound?.displayName ?? "NONE".localized
    }
    
    var isEmpty: Bool {
        
        var isEmpty = true
        self.iterators.forEach {
            if !$0.isEmpty {
                isEmpty = false
            }
            
        }
        
        return isEmpty
    }
    
}
