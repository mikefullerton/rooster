//
//  SoundPreference.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation

struct SoundPreference {
    
    static let RepeatEndlessly = Int.max
    
    let soundNames: [String]
    let repeatCount: Int
    
    init(withSoundNames soundNames: [String],
         repeatCount: Int) {
        self.soundNames = soundNames
        self.repeatCount = repeatCount
    }
    
    init() {
        self.init(withSoundNames: [], repeatCount: -1)
    }
}

