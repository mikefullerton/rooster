//
//  PlaySoundButton.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
import UIKit

class PlaySoundButton : FancyButton, AlarmSoundDelegate {
    
    private(set) var sound: AVAlarmSound? = nil
    private var _url: URL? = nil
    private let timer = SimpleTimer(withName: "PlayButtonAnimationTimer")
    
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
        super.init(frame: CGRect.zero)
        
        self.contentViews = [
            self.imageView(withName: "speaker"),
            self.imageView(withName: "speaker.wave.1"),
            self.imageView(withName: "speaker.wave.2"),
            self.imageView(withName: "speaker.wave.3"),
            self.imageView(withName: "speaker.wave.3"),
        ]
        
        self.contentHorizontalAlignment = .leading
        
        self.contentViewIndex = 0
        
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
    
    private var maxIndex: Int {
        return self.contentViews.count - 1
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
                self.imageView!.tintColor = Theme(for: self).secondaryLabelColor
            } else {
                self.imageView!.tintColor = UIColor.quaternaryLabel
            }
        }
    }
    
    private func refresh() {
        
        guard self.url != nil else {
            self.contentViewIndex = 0
            self.isEnabled = false
            return
        }
        
        self.isEnabled = true
        if self.sound == nil || !self.sound!.isPlaying {
            self.contentViewIndex = 0
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
        imageView.tintColor = Theme(for: self).secondaryLabelColor
        return imageView
    }
    
    func soundWillStartPlaying(_ sound: AlarmSound) {
        self.refresh()

        self.timer.start(withInterval: 0.3, fireCount: SimpleTimer.RepeatEndlessly) { [weak self] timer in
            if let myself = self {
                var index = myself.contentViewIndex
                index += 1
                if index > myself.maxIndex {
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
