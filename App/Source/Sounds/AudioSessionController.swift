//
//  AudioSessionController.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation
import AVFoundation

class AudioSessionController: Loggable {
    
    static var instance = AudioSessionController()

    private(set) var isActive = false
    
    func startAudioSession() {
        self.logger.log("Starting to configure audio session...")
        
        DispatchQueue.global().async {
            do {
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.playback, mode: .default)
                try audioSession.setActive(true)
                self.logger.log("Configured audio session ok")
                self.isActive = true
           } catch let error {
                self.logger.error("Configuring AVAudioSession failed with error: \(error.localizedDescription)")
           }
        }
    }
}


