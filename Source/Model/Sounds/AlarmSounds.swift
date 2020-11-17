//
//  AlarmSounds.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/17/20.
//

import Foundation

class ChickensAlarmSound : BundleAlarmSound {
    init?() {
        super.init(withName: "chickens", extension: "mp3")
    }
}

class RoosterCrowingAlarmSound : BundleAlarmSound {
    init?() {
        super.init(withName: "Rooster-crowing", extension: "mp3")
    }
}
