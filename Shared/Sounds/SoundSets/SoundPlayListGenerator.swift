//
//  SoundSetRandomizer+PlayListGenerator.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/11/21.
//

import Foundation


struct SoundPlayListGenerator: Loggable {
    
    static func generate(withSounds sounds: [SoundFile],
                        randomizer: RandomizationDescriptor) -> [SoundFile] {
        
        if randomizer.behavior == .never {
            self.logger.log("built non-random playlist: \(sounds.map { $0.displayName }.joined(separator:", "))")
            return sounds
        }
        
        var soundBucket:[SoundFile] = sounds
        
        guard soundBucket.count > 0 else {
            return []
        }
        
        self.logger.log("building random playlist")
        
        var newPlayList: [SoundFile] = []

        let minSounds = randomizer.minSounds == 0 ? 1 : randomizer.minSounds
        let maxSounds = randomizer.maxSounds == 0 ? soundBucket.count : randomizer.maxSounds
        
        let count = maxSounds - minSounds + 1
        
//        if count != 1 {
//            count = Int.random(in: minSounds...maxSounds)
//        }
        
        var additionalSounds: [SoundFile] = []
        
        var countDown = count
        while countDown > 0 {
            countDown -= 1
                
            if soundBucket.count == 0 {
                soundBucket = sounds
            }
            
            let randomIndex = Int.random(in: 0...soundBucket.count-1)
            let sound = soundBucket[randomIndex]
            soundBucket.remove(at: randomIndex)
            
            var soundPlayRandomFrequency = RandomizationDescriptor.Frequency.normal
            
            if let randomizer = sound.randomizer {
                soundPlayRandomFrequency = randomizer.frequency
            }
    
            var willPlay = false
            
            switch soundPlayRandomFrequency {
            case .almostNever:
                willPlay = Int.random(in: 1...100) >= 99
                
            case .rare:
                willPlay = Int.random(in: 0...100) >= 90
            
            case .seldom:
                willPlay = Int.random(in: 0...100) >= 75
            
            case .low:
                willPlay = Int.random(in: 0...100) >= 50

            case .normal:
                willPlay = true
                
            case .high:
                willPlay = true
                additionalSounds.append(sound)

            case .frequent:
                willPlay = true
                additionalSounds.append(sound)
                additionalSounds.append(sound)
            }

            self.logger.log("Sound: '\(sound.displayName)', priority: \(soundPlayRandomFrequency.description), willPlay: \(willPlay)")

            if willPlay {
                newPlayList.append(sound)
            }
        }
        
        for sound in additionalSounds {
            if Int.random(in: 0...100) >= 50 {
                self.logger.log("Sound Added!: '\(sound.displayName)'")
                newPlayList.append(sound)
            }
        }
        
        func reset() {
            
        }
        
        var outPlayList: [SoundFile] = []
        
        var randomPlayList: [SoundFile] = []
        for sound in newPlayList {
            if let randomizer = sound.randomizer,
               randomizer.alwaysFirst {
                outPlayList.append(sound)
            } else {
                randomPlayList.append(sound)
            }
        }
        
        while randomPlayList.count > 0 {
            let randomIndex = Int.random(in: 0...randomPlayList.count-1)
            let sound = randomPlayList[randomIndex]
            randomPlayList.remove(at: randomIndex)
            
            outPlayList.append(sound)
        }
        
        self.logger.log("final play list: \(outPlayList.map { $0.displayName }.joined(separator: ", "))")
        
        return outPlayList;
    }
}

