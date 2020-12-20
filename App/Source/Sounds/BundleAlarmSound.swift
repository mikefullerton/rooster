//
//  BundleAlarmSound.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/17/20.
//

import Foundation
import AVFoundation
import OSLog

class BundleAlarmSound : AlarmSound {
    
    private static let logger = Logger(subsystem: "com.apple.rooster", category: "BundleAlarmSound")
        
    weak static var delegate: AlarmSoundDelegate?
    
    var name: String
    
    private let url: URL
    private let player: AVAudioPlayer

    init?(withName name: String,
          extension fileExtension: String = "mp3") {
        
        guard let url = Bundle.main.url(forResource: name, withExtension: fileExtension) else {
            return nil;
        }

        var player: AVAudioPlayer?
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            guard player != nil else {
                return nil
            }
            
        } catch let error {
            BundleAlarmSound.logger.error("Playing sound failed with error: \(error.localizedDescription)")
            return nil
        }

        self.url = url
        self.player = player!
        self.name = name
    }
    
    var isPlaying: Bool {
        return self.player.isPlaying
    }
    
    var duration: TimeInterval {
        return self.player.duration
    }
    
    var numberOfLoops: Int {
        return self.player.numberOfLoops
    }
    
    var volume: Float {
        return self.player.volume
    }
    
    func set(volume: Float, fadeDuration: TimeInterval) {
        self.player.setVolume(volume, fadeDuration:fadeDuration)
    }
    
    var currentTime: TimeInterval {
        return self.player.currentTime
    }
    
    func play(forIdentifier identifier: String) {
        if BundleAlarmSound.delegate != nil {
            BundleAlarmSound.delegate!.soundWillStartPlaying(self, forIdentifier: identifier)
        }
        
        BundleAlarmSound.logger.log("playing sound: \(self.name): for: \(identifier)")
        self.player.numberOfLoops = -1
        self.player.play()
    }
    
    func stop() {
        self.player.stop()
        if BundleAlarmSound.delegate != nil {
            BundleAlarmSound.delegate!.soundDidStopPlaying(self)
        }
    }
    
    static func == (lhs: BundleAlarmSound, rhs: BundleAlarmSound) -> Bool {
        return lhs === rhs
    }
}
