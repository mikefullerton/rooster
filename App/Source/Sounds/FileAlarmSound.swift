//
//  BundleAlarmSound.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/17/20.
//

import Foundation
import AVFoundation
import OSLog

class FileAlarmSound : NSObject, AlarmSound, AVAudioPlayerDelegate {
    
    weak var delegate: AlarmSoundDelegate?
    
    private let url: URL
    private let player: AVAudioPlayer
    private(set) var name: String
    private(set) var behavior: AlarmSoundBehavior
    private let stopTimer: SimpleTimer
    
    init?(withURL url: URL) {

        FileAlarmSound.configureAudioSession()
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
        } catch let error {
            FileAlarmSound.logger.error("Failed to create sound for url: \(url), with error: \(error.localizedDescription)")
            return nil
        }
        self.url = url
        self.name = url.fileName
        self.behavior = AlarmSoundBehavior()
        self.stopTimer = SimpleTimer()
        super.init()
        self.player.delegate = self
    }
    
    deinit {
        self.player.stop()
    }
    
    var isPlaying: Bool {
        return self.player.isPlaying
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
        
    static func == (lhs: FileAlarmSound, rhs: FileAlarmSound) -> Bool {
        return lhs === rhs
    }
    
    func play(withBehavior behavior: AlarmSoundBehavior) {
        self.logger.log("Sound will start playing: \(self.name)")
        self.player.numberOfLoops = 0
        self.player.play()
    }
    
    func stop() {
        self.player.stop()
        self.stopTimer.stop()
        self.logger.log("Sound aborted: \(self.name)")
    }
    
    private func didStop() {
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

    private static var configureAudioSession: () -> Void = {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            FileAlarmSound.logger.log("Configured audio session ok")
        } catch let error {
            FileAlarmSound.logger.error("Configuring AVAudioSession failed with error: \(error.localizedDescription)")
        }
        
        return {}
    }()
    
}


