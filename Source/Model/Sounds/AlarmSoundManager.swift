//
//  AlarmManager.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation

protocol AlarmSoundManagerDelegate : AnyObject {
    func alarmSoundManager(_ manager: AlarmSoundManager, soundWillStartPlaying sound: AlarmSound)
    func alarmSoundManager(_ manager: AlarmSoundManager, soundDidStopPlaying sound: AlarmSound)
}

class AlarmSoundManager: AlarmSoundDelegate  {

    weak var delegate: AlarmSoundManagerDelegate?
    
    private var playing: [AnyHashable: AlarmSound] = [:]
    
    init() {
        BundleAlarmSound.delegate = self
    }
        
    func soundWillStartPlaying<T>(_ sound: AlarmSound, object: T) where T: Identifiable {
        self.playing[object.id] = sound
        if self.delegate != nil {
            self.delegate!.alarmSoundManager(self, soundWillStartPlaying: sound)
        }
    }
    
    func soundDidStopPlaying(_ sound: AlarmSound) {
        var index = -1
        for (objectID, queuedSound) in self.playing {
            index += 1
            if queuedSound === sound {
                self.playing.removeValue(forKey: objectID)
                if self.delegate != nil {
                    self.delegate!.alarmSoundManager(self, soundDidStopPlaying: sound)
                }
                break
            }
        }
    }
    
    func sound<T>(forObject object: T)  -> AlarmSound? where T: Identifiable {
        return self.playing[object.id]
    }
    
}


