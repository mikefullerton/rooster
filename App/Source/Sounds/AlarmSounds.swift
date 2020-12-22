//
//  AlarmSounds.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/17/20.
//

import Foundation

class BundleAlarmSound : FileAlarmSound {
    init?(withName name: String,
          extension fileExtension: String = "mp3") {
        
        guard let url = Bundle.main.url(forResource: name, withExtension: fileExtension) else {
            return nil;
        }
    
        super.init(withURL: url)
    }
    
    
}


class ChickensAlarmSound : BundleAlarmSound {
    init?() {
        super.init(withName: "Chickens", extension: "mp3")
    }
}

class RoosterCrowingAlarmSound : BundleAlarmSound {
    init?() {
        super.init(withName: "Rooster-crowing", extension: "mp3")
    }
}
