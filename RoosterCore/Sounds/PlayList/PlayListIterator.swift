//
//  SingleSoundSetIterator.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/11/21.
//

import Foundation

public class PlayListIterator: PlayListIteratorProtocol, Loggable {
    // what's left to play, in order
    public private(set) var soundPlayerStack: [SoundPlayer]

    // the original playlist (which can possibly change at the start of each iteration)
    private var playList: [SoundPlayer]

    private let soundSet: SoundSet

    public var isRandom: Bool {
        self.soundSet.randomizer.behavior.contains( [.randomizeOrder])
    }

    public var isEmpty: Bool {
        self.playList.isEmpty
    }

    public var description: String {
        """
        \(type(of: self)): \
        playList: \(self.playList.map { $0.description }.joined(separator: ", "))
        """
    }

    public convenience init() {
        self.init(withSoundSet: SoundSet.empty)
    }

    public init(withSoundSet soundSet: SoundSet) {
        self.soundSet = soundSet
        self.soundPlayerStack = []
        self.playList = []
        self.current = nil
    }

    private func updatePlaylist() {
        let playList = PlayListGenerator().generate(withSoundSet: self.soundSet,
                                                    previousPlayList: self.playList)
        self.soundPlayerStack = playList
        self.playList = playList
    }

    public func stop() {
        self.current = nil
        self.soundPlayerStack = []
    }

    public func next() {
        self.current = self.removeSoundFromPlayList()
    }

    private func removeSoundFromPlayList() -> SoundPlayer? {
        if !self.soundPlayerStack.isEmpty {
            let sound = self.soundPlayerStack.first
            self.soundPlayerStack.remove(at: 0)
            return sound
        }
        return nil
    }

    public var isDone: Bool {
        self.current == nil
    }

    public private(set) var current: SoundPlayer?

    public func start() {
        self.updatePlaylist()
        self.next()
    }

    public func stopAndReset() {
        self.current = nil
        self.start()
    }

    public var soundPlayers: [SoundPlayer] {
        self.playList
    }
}
