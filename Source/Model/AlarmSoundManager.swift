//
//  AlarmManager.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation

struct AlarmSoundManager  {
    enum Name : String {
        case chickens = "chickens"
    }
    
    private let chickens: AlarmSound

    static var instance = AlarmSoundManager()
    
    init() {
        if let chickens = BundleAlarmSound(withName: Name.chickens.rawValue) {
            self.chickens = chickens
        } else {
            self.chickens = EmptyAlarmSound()
        }
    }
    
    func playAlarmSound() {
        self.chickens.stop()
        self.chickens.play()
    }

    func silenceAlarmSound() {
        self.chickens.stop()
    }

}
