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
    
    private var queue: [AlarmSound]
    
    init() {
        self.queue = []
        BundleAlarmSound.delegate = self
    }
        
    func soundWillStartPlaying(_ sound: AlarmSound) {
        self.queue.append(sound)
        if self.delegate != nil {
            self.delegate!.alarmSoundManager(self, soundWillStartPlaying: sound)
        }
    }
    
    func soundDidStopPlaying(_ sound: AlarmSound) {
        var index = -1
        for queuedSound in self.queue {
            index += 1
            if queuedSound === sound {
                self.queue.remove(at: index)
                if self.delegate != nil {
                    self.delegate!.alarmSoundManager(self, soundDidStopPlaying: sound)
                }
                break
            }
        }
    }
}


