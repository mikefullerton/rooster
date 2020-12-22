//
//  SoundPreference+AlarmSounds.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation

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
