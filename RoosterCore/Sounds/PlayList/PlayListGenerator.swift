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
    
    public func generate(withSounds sounds: [SoundPlayer],
                         playListRandomizer: PlayListRandomizer) -> [SoundPlayer] {
        
        if playListRandomizer.behavior == .never {
            self.logger.log("built non-random playlist: \(sounds.map { $0.displayName }.joined(separator:", "))")
            return sounds
        }
        
        var soundBucket:[SoundPlayer] = sounds
        
        guard soundBucket.count > 0 else {
            return []
        }
        
        self.logger.log("building random playlist")
        
        var newPlayList: [SoundPlayer] = []

        let minSounds = playListRandomizer.minSounds == 0 ? 1 : playListRandomizer.minSounds
        let maxSounds = playListRandomizer.maxSounds == 0 ? soundBucket.count : playListRandomizer.maxSounds
        
        let count = maxSounds - minSounds + 1
        
//        if count != 1 {
//            count = Int.random(in: minSounds...maxSounds)
//        }
        
        var additionalSounds: [SoundPlayer] = []
        
        var countDown = count
        while countDown > 0 {
            countDown -= 1
                
            if soundBucket.count == 0 {
                soundBucket = sounds
            }
            
            let randomIndex = Int.random(in: 0...soundBucket.count-1)
            let sound = soundBucket[randomIndex]
            soundBucket.remove(at: randomIndex)
            
            var willPlay = false
            
            switch sound.randomizer.frequency {
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
                // TODO: add in more proportional to length of playlist
                additionalSounds.append(sound)

            case .frequent:
                willPlay = true
                // TODO: add in more proportional to length of playlist
                additionalSounds.append(sound)
                additionalSounds.append(sound)
            }

            self.logger.log("Sound: '\(sound.displayName)', priority: \(sound.randomizer.frequency.description), willPlay: \(willPlay)")

            if willPlay {
                newPlayList.append(sound)
            }
        }
        
        for sound in additionalSounds {
            if self.randomizer.randomYesNo {
                self.logger.log("Sound Added!: '\(sound.displayName)'")
                newPlayList.append(sound)
            }
        }
        
        var outPlayList: [SoundPlayer] = []
        
        var randomPlayList: [SoundPlayer] = []
        for sound in newPlayList {
            let randomizer = sound.randomizer
            if randomizer.alwaysFirst {
                outPlayList.append(sound)
            } else {
                randomPlayList.append(sound)
            }
        }
        
        while randomPlayList.count > 0 {
            let randomIndex = self.randomizer.randomize(in: 0...randomPlayList.count-1)
            let sound = randomPlayList[randomIndex]
            randomPlayList.remove(at: randomIndex)
            
            outPlayList.append(sound)
        }
        
        self.logger.log("final play list: \(outPlayList.map { $0.displayName }.joined(separator: ", "))")
        
        return outPlayList;
    }
}

