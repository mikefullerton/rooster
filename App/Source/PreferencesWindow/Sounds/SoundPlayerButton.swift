//
//  SoundPlayerButton.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
import UIKit

class SoundPlayerButton : UIButton, AlarmSoundDelegate {
    let defaultButtonSize:CGSize = CGSize(width: 30, height: 20)
    
    private(set) var sound: AVAlarmSound? = nil
    
    var url: URL? {
        didSet {
            if let sound = self.sound {
                sound.stop()
            }
            
            self.sound = nil
            self.refresh()
        }
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: self.defaultButtonSize.width, height: self.defaultButtonSize.height))
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.setImage(self.playImage, for: .normal)
        self.contentHorizontalAlignment = .left
        self.frame = CGRect(x: 0, y: 0, width: self.defaultButtonSize.width, height: self.defaultButtonSize.height)
        self.addTarget(self, action: #selector(playSound(_:)), for: .touchUpInside)
        self.isEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refresh() {
        if let sound = self.sound {
            if sound.isPlaying {
                self.setImage(self.muteImage, for: .normal)
            } else {
                self.setImage(self.playImage, for: .normal)
            }
        } else {
            self.setImage(self.playImage, for: .normal)
            self.isEnabled = false
        }
    }
    
    @objc func playSound(_ sender: UIButton) {
//        print("Play sound: \(self.sound)")
        
        if let sound = self.sound {
            if sound.isPlaying {
                sound.stop()
            } else {
                self.setImage(self.muteImage, for: .normal)
                sound.play(withBehavior: AlarmSoundBehavior(playCount: 1, timeBetweenPlays: 0, fadeInTime: 0))
            }
        } else if let url = self.url,
           let sound = AVAlarmSound(withURL: url) {
            self.sound = sound
            sound.delegate = self
            
            sound.play(withBehavior: AlarmSoundBehavior(playCount: 1, timeBetweenPlays: 0, fadeInTime: 0))
        }

        self.refresh()
    }

    lazy var playImage : UIImage? = {
        return UIImage(systemName: "speaker.fill")
    }()

    lazy var muteImage : UIImage? = {
        return UIImage(systemName: "speaker.wave.3.fill")
    }()
    
    func soundWillStartPlaying(_ sound: AlarmSound) {
        self.refresh()
    }
    
    func soundDidStopPlaying(_ sound: AlarmSound) {
        self.refresh()
    }
    
    
    
}
