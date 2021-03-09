//
//  NativeSoundPlayer.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/1/21.
//

import Foundation
import Cocoa


class NativeSoundPlayer : NSObject, SoundPlayerProtocol, NSSoundDelegate, Loggable {
    
    private weak var soundFile: SoundFile?
    
    private var sound: NSSound?
    
    init(withSoundFile soundFile: SoundFile) {
        self.soundFile = soundFile
    }
    
    weak var delegate: SoundDelegate?
    
    var url: URL {
        return self.soundFile?.absolutePath ?? URL.empty
    }
    
    var id: String {
        return self.soundFile?.id ?? ""
    }
    
    var displayName: String {
        return self.soundFile?.displayName ?? ""
    }
    
    public var volume: Float {
        if let sound = self.sound {
            return sound.volume
        }
        return 0
    }
    
    public var duration: TimeInterval {
        if let sound = self.sound {
            return sound.duration
        }
        
        return 0
    }
    
    var isPlaying: Bool {
        if let sound = self.sound {
            return sound.isPlaying
        }
        
        return false
    }
    
    public var currentTime: TimeInterval {
        if let sound = self.sound {
            return sound.currentTime
        }
        
        return 0
    }
    
    public func set(volume: Float, fadeDuration: TimeInterval) {
        if let sound = self.sound {
            sound.volume = volume
        }
    }

    private func createPlayerIfNeeded() {
        guard self.sound == nil else {
            return
        }
        
        if  let sound = NSSound(contentsOf: self.url, byReference: true){
            sound.setName(self.displayName)
            sound.delegate = self
            self.sound = sound
            
        } else {
            self.logger.error("Failed to create sound for url: \(self.url)")
            return
        }
    }
    
    func play(withBehavior behavior: SoundBehavior) {
        self.createPlayerIfNeeded()
        
        if let sound = self.sound {
            self.logger.log("playing sound: \(self.soundFile?.description ?? "nil")")
            self.delegate?.soundWillStartPlaying(self)
            sound.loops = false
            sound.play()
            self.delegate?.soundDidStartPlaying(self)
        }
    }
    
    private func didStop() {
        self.sound?.stop()
        self.sound = nil
        self.logger.log("sound did stop: \(self.soundFile?.description ?? "nil")")
        
        if self.delegate == nil {
            self.logger.log("delegate is nil")
        }
        self.delegate?.soundDidStopPlaying(self)
    }
    
    func stop() {
        self.didStop()
    }
    
    func sound(_ sound: NSSound, didFinishPlaying flag: Bool) {
        self.didStop()
    }
    
}
