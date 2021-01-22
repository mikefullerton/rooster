//
//  BundleAlarmSound.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/17/20.
//

import Foundation
import AVFoundation

extension URL {
    
    var AVFileType: AVFileType? {
        if self.absoluteString.hasSuffix("mp3") {
            return .mp3
        }
        
        if self.absoluteString.hasSuffix("wav") {
            return .wav
        }
        
        return nil
    }
    
}

class AVAlarmSound : NSObject, AlarmSound, AVAudioPlayerDelegate {
    weak var delegate: AlarmSoundDelegate?
    
    var identifier: String
    
    private(set) var behavior: AlarmSoundBehavior
    let url: URL
    
    private var player: AVAudioPlayer?
    private let stopTimer: SimpleTimer
    
    private(set) var isPlaying: Bool
    
    init(withURL url: URL) {
        self.url = url
        self.behavior = AlarmSoundBehavior()
        self.stopTimer = SimpleTimer(withName: "AVAlarmSoundStopTimer")
        self.identifier = ""
        self.isPlaying = false
        self.player = nil
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: PreferencesController.DidChangeEvent, object: nil)
    }
    
    deinit {
        self.stopTimer.stop()
        self.fadeOutAndStop()
    }
    
    var name: String {
        if self.url.isRandomizedSound {
            if let player = self.player {
                return "randomized: \(player.url!.soundName)"
            } else {
                return "randomized: (not loadeded)"
            }
        }
        
        return self.url.soundName
    }
    
    private func createPlayerIfNeeded() {
        guard self.player == nil else {
            return
        }
        
        var url = self.url
        if url.isRandomizedSound {
            url = Bundle.availableSoundResources.randomElement()!
        }
        
        guard let avFileType = url.AVFileType else {
            AVAlarmSound.logger.error("Unexpected file type for url: \(url)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url, fileTypeHint: avFileType.rawValue)
            player.delegate = self
            self.player = player
            
        } catch let error {
            AVAlarmSound.logger.error("Failed to create sound for url: \(url), with error: \(error.localizedDescription)")
            return
        }
        
        self.updateVolume()
    }
    
    private func updateVolume() {
        if let player = self.player {
            player.setVolume(AppDelegate.instance.preferencesController.preferences.sounds.volume, fadeDuration: 0)
        }
    }
    
    @objc func preferencesDidChange(_ sender: Notification) {
        self.updateVolume()
    }

    var volume: Float {
        if let player = self.player {
            return player.volume
        }
        return 0
    }
    
    var duration: TimeInterval {
        if let player = self.player {
            return player.duration
        }
        
        return 0
    }
    
    func set(volume: Float, fadeDuration: TimeInterval) {
        if let player = self.player {
            player.setVolume(volume, fadeDuration:fadeDuration)
        }
    }
    
    var currentTime: TimeInterval {
        if let player = self.player {
            return player.currentTime
        }
        
        return 0
    }
        
    static func == (lhs: AVAlarmSound, rhs: AVAlarmSound) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func play(withBehavior behavior: AlarmSoundBehavior) {
        self.createPlayerIfNeeded()
        self.isPlaying = true
        self.logger.log("Sound will start playing: \(self.name)")
        if let delegate = self.delegate {
            delegate.soundWillStartPlaying(self)
        }

        DispatchQueue.main.async {
            if let player = self.player {
                player.numberOfLoops = 0
                player.setVolume(1, fadeDuration: 0.2)
                player.play()
            } else {
                self.didStop()
            }
        }
    }
    
    func stop() {
        self.logger.log("Sound will be aborted: \(self.name)")
        self.didStop()
    }
    
    func fadeOutAndStop() {
        if let player = self.player,
            player.isPlaying {
            
            player.setVolume(0, fadeDuration: 0.2)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(300)) {
                player.stop()
            }
        }
    
    }
    
    private func didStop() {
        self.logger.log("Sound stopped: \(self.name)")
        self.isPlaying = false
        if let player = self.player {
            
            self.fadeOutAndStop()
            
            if self.url.isRandomizedSound {
                player.delegate = nil
                self.player = nil
            }
        }
        self.stopTimer.stop()
        
        if let delegate = self.delegate {
            delegate.soundDidStopPlaying(self)
        }
    }
    
    private func startStopNotify() {
        if self.behavior.timeBetweenPlays > 0 {
            self.stopTimer.start(withInterval: self.behavior.timeBetweenPlays) { time in
                self.didStop()
            }
        } else {
            self.didStop()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        self.logger.error("Sound \(self.name), Decoding error: \(error?.localizedDescription ?? "nil" )")
        self.startStopNotify()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.logger.log("Sound did stop playing: \(self.name)")
        self.startStopNotify()
    }
}

extension AVAlarmSound {
    static func alarmSounds(withURLs urls:[URL]) -> [AlarmSound] {
        var sounds:[AlarmSound] = []
        for url in urls {
            let alarm = AVAlarmSound(withURL: url)
            sounds.append(alarm)
            AVAlarmSound.logger.error("Loaded sound for URL: \(url)")
        }
        return sounds
    }
    
}


