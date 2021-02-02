//
//  Sound+DisplayName.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/3/21.
//

import Foundation

extension SoundPreferences.Sound {
    var displayName: String {
        if self.random {
            return "RANDOM".localized
        }
        
        return self.soundName
    }
}
