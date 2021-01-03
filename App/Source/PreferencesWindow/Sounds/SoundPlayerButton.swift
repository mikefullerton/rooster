//
//  SoundPlayerButton.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
import UIKit

class SoundPlayerButton : UIButton, AlarmSoundDelegate {
    
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
        super.init(frame: CGRect.zero)
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.updateImage(self.playImage)
        self.contentHorizontalAlignment = .left
        self.addTarget(self, action: #selector(playSound(_:)), for: .touchUpInside)
        self.isEnabled = false
        
        self.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateImage(_ image: UIImage?) {
        if let updatedImage = image {
            self.setImage(updatedImage, for: .normal)
        }
        if let imageView = self.imageView {
            
            self.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 22,weight: .regular),
                                                 forImageIn: UIControl.State.normal)
            
            imageView.tintColor = UIColor.secondaryLabel
        }
    }
    
    func refresh() {
        if let sound = self.sound {
            if sound.isPlaying {
                self.updateImage(self.muteImage)
            } else {
                self.updateImage(self.playImage)
            }
        } else {
            self.updateImage(self.playImage)
            self.isEnabled = false
        }
    }
    
    var isPlaying: Bool {
        return self.sound?.isPlaying ?? false
    }
    
    func togglePlayingState() {
        if let sound = self.sound {
            if sound.isPlaying {
                sound.stop()
            } else {
                self.updateImage(self.muteImage)
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
    
    @objc func playSound(_ sender: UIButton) {
        self.togglePlayingState()
    }

    lazy var playImage : UIImage? = {
        return UIImage(systemName: "speaker")
    }()

    lazy var muteImage : UIImage? = {
        return UIImage(systemName: "speaker.wave.3")
    }()
    
    private var _intrinsicSize: CGSize? = nil
    
    override var intrinsicContentSize: CGSize {
        
        if let size = self._intrinsicSize {
            return size
        }
        
        var size = super.intrinsicContentSize
        size.width *= 2.0
        self._intrinsicSize = size
        
        return size
    }
    
    func soundWillStartPlaying(_ sound: AlarmSound) {
        self.refresh()
    }
    
    func soundDidStopPlaying(_ sound: AlarmSound) {
        self.refresh()
    }
    
    
    
}
