//
//  SoundPlayerButton.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
import UIKit

class SoundPlayerButton : ContentViewButton, AlarmSoundDelegate {
    
    private(set) var sound: AVAlarmSound? = nil
    
    private var _url: URL?
    private let timer: SimpleTimer
    
    enum Image: Int {
        case play1
        case play2
        case play3
        case play4
    }
    
    var url: URL? {
        get {
            return self._url
        }
        set(url) {
            if url != self._url {
                self._url = url
                
                if let sound = self.sound {
                    sound.stop()
                }
                
                self.sound = nil
                self.refresh()
            }
        }
    }
    
    init() {
        self.timer = SimpleTimer()
        
        super.init(frame: CGRect.zero)
        
        self.contentViews = [
            self.imageView(withName: "speaker"),
            self.imageView(withName: "speaker.wave.1"),
            self.imageView(withName: "speaker.wave.2"),
            self.imageView(withName: "speaker.wave.3"),
        ]
        self.contentHorizontalAlignment = .leading
        
        self.contentViewIndex = Image.play1.rawValue
        
        self.addTarget(self, action: #selector(playSound(_:)), for: .touchUpInside)
        
        self.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    deinit {
        self.timer.stop()
        
        if let sound = self.sound {
            sound.stop()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isEnabled: Bool {
        get { return super.isEnabled }
        set(isEnabled) {
            
            if self.url == nil {
                super.isEnabled = false
            } else {
                super.isEnabled = isEnabled
            }
            
            if super.isEnabled {
                self.imageView!.tintColor = UIColor.secondaryLabel
            } else {
                self.imageView!.tintColor = UIColor.quaternaryLabel
            }
        }
    }
    
    private func refresh() {
        
        guard self.url != nil else {
            self.contentViewIndex = Image.play1.rawValue
            self.isEnabled = false
            return
        }
        
        self.isEnabled = true
        if self.sound == nil || !self.sound!.isPlaying {
            self.contentViewIndex = Image.play1.rawValue
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
                sound.play(withBehavior: AlarmSoundBehavior(playCount: 1, timeBetweenPlays: 0, fadeInTime: 0))
            }
        } else if let url = self.url {
            let sound = AVAlarmSound(withURL: url) 
            sound.delegate = self
            self.sound = sound
            
            sound.play(withBehavior: AlarmSoundBehavior(playCount: 1, timeBetweenPlays: 0, fadeInTime: 0))
        }

        self.refresh()
    }
    
    @objc func playSound(_ sender: UIButton) {
        self.togglePlayingState()
    }

    private func imageView(withName name: String) -> UIImageView {
        let image = UIImage(systemName: name)
        let imageView = UIImageView(image: image)
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 22,weight: .regular)
        imageView.tintColor = UIColor.secondaryLabel
        return imageView
    }
    
    func soundWillStartPlaying(_ sound: AlarmSound) {
        self.refresh()

        self.contentViewIndex = Image.play2.rawValue
        
        self.timer.start(withInterval: 0.3, fireCount: SimpleTimer.RepeatEndlessly) { [weak self] timer in
            if let myself = self {
                var index = myself.contentViewIndex
                index += 1
                if index >= myself.contentViewCount {
                    index = 0 // Image.play2.rawValue
                }

                myself.contentViewIndex = index
            }
        }
        
    }
    
    func soundDidStopPlaying(_ sound: AlarmSound) {
        self.timer.stop()
        self.sound = nil
        self.refresh()
    }
    
    
    
}
