//
//  AlarmSound.swift
//  Rooster
//
//  Created by Mike Fullerton on 11/13/20.
//

import Foundation
import AVFoundation

var player: AVAudioPlayer?

struct AlarmSound {

    enum Name : String {
        case chickens = "chickens"
    }
    
    let url: URL
    
    private let player: AVAudioPlayer
    
    init?(withName name: Name) {

        guard let url = Bundle.main.url(forResource: name.rawValue, withExtension: "mp3") else {
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
    
    func play() {
        self.player.numberOfLoops = -1
        self.player.play()
    }
    
    func stop() {
        self.player.stop()
    }
}
