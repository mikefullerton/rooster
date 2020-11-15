//
//  AlarmSound.swift
//  Rooster
//
//  Created by Mike Fullerton on 11/13/20.
//

import Foundation
import AVFoundation

var player: AVAudioPlayer?

protocol AlarmSound {
    var isPlaying: Bool { get }
    
    var duration: TimeInterval { get }
    
    var currentTime: TimeInterval { get }
    
    var numberOfLoops: Int { get }
    
    var volume: Float { get }

    func set(volume: Float, fadeDuration: TimeInterval)
    
    func play()
    
    func stop()
}

struct BundleAlarmSound : AlarmSound {
    
    let url: URL
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
            print(error.localizedDescription)
            return nil
        }

        self.url = url
        self.player = player!
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
    
    func play() {
        self.player.numberOfLoops = -1
        self.player.play()
    }
    
    func stop() {
        self.player.stop()
    }
}

struct EmptyAlarmSound : AlarmSound {
    var isPlaying: Bool {
        return false
    }
    
    func play() {
    }
    
    func stop() {
    }
    
    var duration: TimeInterval {
        return 0
    }
    
    var numberOfLoops: Int {
        return 0
    }
    
    var volume: Float {
        return 0
    }
    
    func set(volume: Float, fadeDuration: TimeInterval) {
    }
    
    var currentTime: TimeInterval {
        return 0
    }
}
