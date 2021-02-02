//
//  PlaySoundButton.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class PlaySoundButton : FancyButton, AlarmSoundDelegate {
    
    private(set) var alarmSound: AlarmSound? = nil
    private var _url: URL? = nil
    private let timer = SimpleTimer(withName: "PlayButtonAnimationTimer")
    
    var url: URL? {
        get {
            return self._url
        }
        set(url) {
            if url != self._url {
                self._url = url
                
                if let alarmSound = self.alarmSound {
                    alarmSound.stop()
                }
                
                self.alarmSound = nil
            }
            
            self.refresh()
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
  
        self.alignment = .left
//        self.contentHorizontalAlignment = .leading
        
        self.contentViewIndex = 0
        
        self.target = self
        self.action = #selector(playSound(_:))
        
//        self.setContentHuggingPriority(.windowSizeStayPut, for: .horizontal)
//        self.setContentHuggingPriority(.windowSizeStayPut, for: .vertical)
        
        self.toolTip = "Play Sound"
    }
    
    deinit {
        self.timer.stop()
        
        if let alarmSound = self.alarmSound {
            alarmSound.stop()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var maxIndex: Int {
        return self.contentViews.count - 1
    }
    
    private func refresh() {
        
        guard self.url != nil else {
            self.contentViewIndex = 0
            self.isEnabled = false
            return
        }
        
        self.isEnabled = true
        if self.alarmSound == nil || !self.alarmSound!.isPlaying {
            self.contentViewIndex = 0
        }
    }
    
    var isPlaying: Bool {
        return self.alarmSound?.isPlaying ?? false
    }
    
    func togglePlayingState() {
        if let alarmSound = self.alarmSound {
            if alarmSound.isPlaying {
                alarmSound.stop()
            } else {
                alarmSound.play(withBehavior: AlarmSoundBehavior(playCount: 1, timeBetweenPlays: 0, fadeInTime: 0))
            }
        } else if let url = self.url {
            let alarmSound = URLAlarmSound(withURL: url)
            alarmSound.delegate = self
            self.alarmSound = alarmSound
            
            alarmSound.play(withBehavior: AlarmSoundBehavior(playCount: 1, timeBetweenPlays: 0, fadeInTime: 0))
        }

        self.refresh()
    }
    
    @objc func playSound(_ sender: SDKButton) {
        self.togglePlayingState()
    }

    private func imageView(withName name: String) -> SDKImageView {
        guard let image = NSImage(systemSymbolName: name, accessibilityDescription: name) else {
            return NSImageView()
        }
        
        let imageView = NSImageView(image: image)
        imageView.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 22,weight: .regular)
        imageView.contentTintColor = Theme(for: self).secondaryLabelColor
        return imageView
    }
    
    func soundWillStartPlaying(_ alarmSound: AlarmSound) {
        self.refresh()

        self.timer.start(withInterval: 0.3, fireCount: SimpleTimer.RepeatEndlessly) { [weak self] timer in
            if let myself = self {
                var index = myself.contentViewIndex
                index += 1
                if index > myself.maxIndex {
                    index = 0 // SDKImage.play2.rawValue
                }

                myself.contentViewIndex = index
            }
        }
    }
    
    func soundDidStopPlaying(_ alarmSound: AlarmSound) {
        self.timer.stop()
        self.alarmSound = nil
        self.refresh()
    }
}
