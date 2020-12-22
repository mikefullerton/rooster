//
//  BundleAlarmSound.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/17/20.
//

import Foundation
import AVFoundation
import OSLog

class FileAlarmSound : AlarmSound {
        
    weak static var delegate: AlarmSoundDelegate?
    
    private let url: URL
    private let player: AVAudioPlayer
    
    init?(withURL url: URL) {

        var player: AVAudioPlayer?
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            guard player != nil else {
                return nil
            }
            
        } catch let error {
            AlarmSound.logger.error("Playing sound failed with error: \(error.localizedDescription)")
            return nil
        }

        self.url = url
        self.player = player!
        super.init(withName: url.fileName)
    }
    
    override var isPlaying: Bool {
        return self.player.isPlaying
    }
    
    override var volume: Float {
        return self.player.volume
    }
    
    override var duration: TimeInterval {
        return self.player.duration
    }
    
    override func set(volume: Float, fadeDuration: TimeInterval) {
        self.player.setVolume(volume, fadeDuration:fadeDuration)
    }
    
    override var currentTime: TimeInterval {
        return self.player.currentTime
    }
    
    override func startPlayingSound() -> TimeInterval {
        self.player.numberOfLoops = 0
        self.player.play()
        return self.duration + self.behavior.timeBetweenPlays
    }
    
    override func stopPlayingSound() {
        self.player.stop()
    }
    
    static func == (lhs: FileAlarmSound, rhs: FileAlarmSound) -> Bool {
        return lhs === rhs
    }
}


