//
//  MultipleSoundSetIterator.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/6/21.
//

import Foundation

public class MultiPlayListIterator: PlayListIteratorProtocol {
    public private(set) var current: SoundPlayer?

    private let iterators: [PlayListIteratorProtocol]
    private var iteratorStack: [PlayListIteratorProtocol] = []
    private var currentIterator: PlayListIteratorProtocol?

    public var description: String {
        """
        \(type(of: self)): \
        iterators: \(self.iterators.map { $0.description }.joined(separator: ", "))
        """
    }

    public var isRandom: Bool {
        false
    }

    public var isEmpty: Bool {
        self.iterators.isEmpty
    }

    public init(withIterators soundSetIterators: [PlayListIteratorProtocol]) {
        self.iterators = soundSetIterators // soundSetIterators.filter { $0.sounds.count > 0 }
        self.iteratorStack = []
        self.currentIterator = nil
    }

    // MARK: private

    private func updatePlaylist() {
        if !self.iterators.isEmpty {
            self.iteratorStack = self.iterators
        }
    }

    private func nextIterator() {
        self.currentIterator = nil
        self.current = nil

        while !self.iteratorStack.isEmpty {
            let first = self.iteratorStack.first!
            self.iteratorStack.remove(at: 0)

            first.start()

            if !first.isDone {
                self.current = first.current
                self.currentIterator = first
                break
            }
        }
    }

    public func start() {
        self.current = nil
        self.iteratorStack = []
        self.updatePlaylist()
        self.nextIterator()
    }

    public func next() {
        self.current = nil
        if let currentIterator = self.currentIterator {
            currentIterator.next()
            if !currentIterator.isDone {
                self.current = currentIterator.current
            } else {
                self.nextIterator()
            }
        }
    }

    public var isDone: Bool {
        self.current == nil || self.currentIterator == nil
    }

    public func stop() {
        self.iteratorStack = []
        self.currentIterator = nil
        self.current = nil
    }

    public var soundPlayers: [SoundPlayer] {
        var soundPlayers: [SoundPlayer] = []
        self.iterators.forEach { soundPlayers.append(contentsOf: $0.soundPlayers) }
        return soundPlayers
    }
}
