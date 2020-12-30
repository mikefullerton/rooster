//
//  BundleAlarmSound.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/17/20.
//

import Foundation
import AVFoundation
import UIKit

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
    
    private(set) var name: String
    private(set) var behavior: AlarmSoundBehavior
    
    private let url: URL
    private let player: AVAudioPlayer
    private let stopTimer: SimpleTimer
    
    private(set) var isPlaying: Bool
    
    init?(withURL url: URL) {
        
        guard let avFileType = url.AVFileType else {
            AVAlarmSound.logger.error("Unexpected file type for url: \(url)")
            return nil
        }
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url, fileTypeHint: avFileType.rawValue)
        } catch let error {
            AVAlarmSound.logger.error("Failed to create sound for url: \(url), with error: \(error.localizedDescription)")
            return nil
        }
        self.url = url
        self.name = url.fileName
        self.behavior = AlarmSoundBehavior()
        self.stopTimer = SimpleTimer()
        self.identifier = ""
        self.isPlaying = false
        super.init()
        self.player.delegate = self
        self.updateVolume()
        
        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: PreferencesController.DidChangeEvent, object: nil)
    }
    
    deinit {
        self.player.stop()
    }
    
    func updateVolume() {
        self.player.setVolume(PreferencesController.instance.preferences.sounds.volume, fadeDuration: 0)
    }
    
    @objc func preferencesDidChange(_ sender: Notification) {
        self.updateVolume()
    }

    var volume: Float {
        return self.player.volume
    }
    
    var duration: TimeInterval {
        return self.player.duration
    }
    
    func set(volume: Float, fadeDuration: TimeInterval) {
        self.player.setVolume(volume, fadeDuration:fadeDuration)
    }
    
    var currentTime: TimeInterval {
        return self.player.currentTime
    }
        
    static func == (lhs: AVAlarmSound, rhs: AVAlarmSound) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func play(withBehavior behavior: AlarmSoundBehavior) {
        self.isPlaying = true
        self.logger.log("Sound will start playing: \(self.name)")
        DispatchQueue.main.async {
            self.player.numberOfLoops = 0
            self.player.play()
        }
    }
    
    func stop() {
        self.isPlaying = false
        self.player.stop()
        self.stopTimer.stop()
        self.logger.log("Sound aborted: \(self.name)")
    }
    
    private func didStop() {
        self.isPlaying = false
        if let delegate = self.delegate {
            delegate.soundDidStopPlaying(self)
            self.logger.log("Sound stopped and notified delgate: \(self.name)")
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
            if let alarm = AVAlarmSound(withURL: url) {
                sounds.append(alarm)
                AVAlarmSound.logger.error("Loaded sound for URL: \(url)")
            } else {
                AVAlarmSound.logger.error("Failed to load sound for URL: \(url)")
            }
        }
        return sounds
    }
    
}
