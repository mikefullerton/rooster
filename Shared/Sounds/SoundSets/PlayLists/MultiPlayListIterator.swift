//
//  MultipleSoundSetIterator.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/6/21.
//

import Foundation

class MultiPlayListIterator : PlayListIteratorProtocol {
    
    private let iterators:[PlayListIteratorProtocol]
    private var iteratorStack: [PlayListIteratorProtocol]?
    private var currentIterator: PlayListIteratorProtocol?
    private(set) var state: PlayListIteratorState

    init(withIterators soundSetIterators: [PlayListIteratorProtocol]) {
        self.iterators = soundSetIterators.filter { $0.sounds.count > 0 }
        self.iteratorStack = nil
        self.currentIterator = nil
        self.state = .idle
    }

    private func didStopIterating() {
        self.iteratorStack = nil
        self.currentIterator = nil
        self.state = .done
    }
    
    func stop() {
        if self.state == .iterating {
            self.didStopIterating()
        }
        self.iterators.forEach { $0.stop() }
    }
    
    func resetToIdleState() {
        self.stop()
        self.state = .idle
    }
    
    private func rebuildIteratorStack() {
        if self.iterators.count > 0 {
            self.iteratorStack = self.iterators
            self.iteratorStack!.forEach { $0.resetToIdleState() }
            
            if self.iteratorStack!.count > 0 {
                self.currentIterator = self.iteratorStack!.first
                self.iteratorStack!.remove(at: 0)
            }
        }
    }
 
    func step() -> SoundFile? {
        
        switch(self.state) {
        case .idle:
            self.state = .iterating
            self.rebuildIteratorStack()
            
        case .done:
            self.state = .idle
            
        case .iterating:
            break
        }

        if self.state == .iterating {
           if let sound = self.advanceCurrentIterator() {
                self.updateIteratorState()
                return sound
            }
            
            self.updateIteratorState()
            if let sound = self.advanceCurrentIterator() {
                self.updateIteratorState()
                return sound
            }
        }
        
        return nil;
    }
    
    var sounds: [SoundFile] {
        var sounds:[SoundFile] = []
        self.iterators.forEach {
            let iteratorSounds = $0.sounds
            if iteratorSounds.count > 0 {
                sounds.append(contentsOf: iteratorSounds)
            }
        }
        return sounds
    }

    var soundCount: Int {
        return self.sounds.count
    }

    // MARK: private
    
    private func updateIteratorState() {
        if let currentIterator = self.currentIterator, currentIterator.state == .iterating {
            return
        }
        
        if var iteratorStack = self.iteratorStack {
            iteratorStack.forEach { $0.resetToIdleState() }
            while iteratorStack.count > 0 && self.currentIterator == nil {
                let first = iteratorStack.first!
                iteratorStack.remove(at: 0)
                self.currentIterator = first
            }
        }
        
        if self.currentIterator == nil {
            self.didStopIterating()
        }
    }
    
    private func advanceCurrentIterator() -> SoundFile? {
        if let currentIterator = self.currentIterator,
           let sound = currentIterator.step() {
            
            return sound
        }
        
        return nil
    }
    
    private func createIteratorStack() {
        if self.iterators.count > 0 {
            self.iteratorStack = self.iterators
            
        } else {
            self.iteratorStack = nil
        }
    
    }
    
    
}
