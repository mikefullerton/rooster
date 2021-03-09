//
//  SoundSetRandomizer+PlayListGenerator.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/11/21.
//

import Foundation

public struct PlayListGenerator: Loggable {
    let randomizer: RandomizerProtocol

    public init() {
        self.randomizer = Randomizer()
    }

    public init(withRandomizer randomizer: RandomizerProtocol) {
        self.randomizer = randomizer
    }

    // swiftlint:disable function_body_length cyclomatic_complexity

    public func generate(withSoundSet soundSet: SoundSet,
                         previousPlayList: [SoundPlayer]) -> [SoundPlayer] {
        let playListRandomizer = soundSet.randomizer

        if !previousPlayList.isEmpty && !playListRandomizer.behavior.contains( .regenerateEachPlay ) {
            return previousPlayList
        }

        let sounds = soundSet.soundPlayers
        var soundBucket: [SoundPlayer] = sounds

        guard !soundBucket.isEmpty else {
            return []
        }

        let count = sounds.count
        let soundFolder = soundSet.soundFolder

        self.logger.log("building playlist for soundSet: \(soundSet)")

        var newPlayList: [SoundPlayer] = []
        var additionalSounds: [SoundPlayer] = []

        var countDown = count
        while countDown > 0 {
            countDown -= 1

            if !soundBucket.isEmpty {
                soundBucket = sounds
            }

            var soundIndex = 0

            if playListRandomizer.behavior.contains(.randomizeOrder) {
                soundIndex = Int.random(in: 0...soundBucket.count - 1)
            }

            let originalSoundPlayer = soundBucket[soundIndex]

            var actualSoundPlayer = originalSoundPlayer

            soundBucket.remove(at: soundIndex)

            var willPlay = false

            if originalSoundPlayer.randomizer.behavior == .replaceWithRandomSoundFromSoundFolder {
                actualSoundPlayer = SoundPlayer(withSoundFile: soundFolder.randomSoundFile, randomizer: originalSoundPlayer.randomizer)
            }

            switch actualSoundPlayer.randomizer.frequency {
            case .almostNever:
                willPlay = self.randomizer.randomChoice(withLikelihoodPercent: 0.01)

            case .rare:
                willPlay = self.randomizer.randomChoice(withLikelihoodPercent: 0.1)

            case .seldom:
                willPlay = self.randomizer.randomChoice(withLikelihoodPercent: 0.25)

            case .low:
                willPlay = self.randomizer.randomChoice(withLikelihoodPercent: 0.50)

            case .normal:
                willPlay = true

            case .high:
                willPlay = true
                // FUTURE: add in more proportional to length of playlist
                additionalSounds.append(actualSoundPlayer)

            case .frequent:
                willPlay = true
                // FUTURE: add in more proportional to length of playlist
                additionalSounds.append(actualSoundPlayer)
                additionalSounds.append(actualSoundPlayer)
            }

            self.logger.log("""
                Sound: '\(actualSoundPlayer.displayName)', \
                priority: \(actualSoundPlayer.randomizer.frequency.description), \
                willPlay: \(willPlay)
                """)

            if willPlay {
                newPlayList.append(actualSoundPlayer)
            }
        }

        for sound in additionalSounds where self.randomizer.randomYesNo {
            self.logger.log("Sound Added!: '\(sound.displayName)'")
            newPlayList.append(sound)
        }

        var outPlayList: [SoundPlayer] = []

        var randomPlayList: [SoundPlayer] = []
        for sound in newPlayList {
            let randomizer = sound.randomizer
            if randomizer.behavior.contains( .alwaysFirst ) {
                outPlayList.append(sound)
            } else {
                randomPlayList.append(sound)
            }
        }

        if !playListRandomizer.behavior.contains([.randomizeOrder]) {
            randomPlayList.forEach { outPlayList.append($0) }
            return outPlayList
        }

        while !randomPlayList.isEmpty {
            let randomIndex = self.randomizer.randomize(in: 0...randomPlayList.count - 1)
            let sound = randomPlayList[randomIndex]
            randomPlayList.remove(at: randomIndex)

            outPlayList.append(sound)
        }

        self.logger.log("final play list: \(outPlayList.map { $0.displayName }.joined(separator: ", "))")

        return outPlayList
    }

    // swiftlint:enable function_body_length cyclomatic_complexity

}
