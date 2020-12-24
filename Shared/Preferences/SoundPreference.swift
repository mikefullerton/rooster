//
//  SoundPreference.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation

struct SoundPreference {
    
    static let RepeatEndlessly = AlarmSoundBehavior.RepeatEndlessly
    
    let soundNames: [String]
    let playCount: Int
    let startDelay: Int
    
    init(withSoundNames soundNames: [String],
         playCount: Int,
         startDelay: Int) {
        self.soundNames = soundNames
        self.playCount = playCount
        self.startDelay = startDelay
    }
    
    init() {
        self.init(withSoundNames: [], playCount: 0, startDelay: 0)
    }
}

extension SoundPreference {
    
    var soundURLs: [URL] {
        
        var outURLs:[URL] = []
        
        let availableURLs = Bundle.availableSoundResources
        
        for name in self.soundNames {
            for url in availableURLs {
                let fileName = url.fileName
                if fileName == name {
                    outURLs.append(url)
                }
            }
        }
        
        return outURLs
    }
}
