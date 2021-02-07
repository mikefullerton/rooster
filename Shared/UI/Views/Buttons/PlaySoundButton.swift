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

protocol PlaySoundButtonDelegate : AnyObject {
    func playButtonSoundWillStart(_ playSoundButton: PlaySoundButton)
    func playButtonSoundDidStart(_ playSoundButton: PlaySoundButton)
    func playButtonSoundDidStop(_ playSoundButton: PlaySoundButton)
    func playButton(_ playSoundButton: PlaySoundButton, alarmSoundDidChange alarmSound: AlarmSound?)
}

class PlaySoundButton : FancyButton, SoundSetAlarmSoundDelegate {
    
    weak var delegate: PlaySoundButtonDelegate?
    
    private var _alarmSound: AlarmSound? = nil
    private let timer = SimpleTimer(withName: "PlayButtonAnimationTimer")
    
    var alarmBehavior = AlarmSoundBehavior(playCount: 1, timeBetweenPlays: 0, fadeInTime: 0)
   
    var alarmSound: AlarmSound? {
        get {
            return self._alarmSound
        }
        set(alarmSound) {
            if alarmSound?.id != self._alarmSound?.id {
                self._alarmSound?.delegate = nil
                
                self._alarmSound = alarmSound
                
                if let alarmSound = self.alarmSound {
                    alarmSound.stop()
                }
                
                self.delegate?.playButton(self, alarmSoundDidChange: self._alarmSound)
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
        self.contentViewIndex = 0
        self.target = self
        self.action = #selector(playSound(_:))
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
        
        guard self.alarmSound != nil else {
            self.contentViewIndex = 0
            self.isEnabled = false
            return
        }
        
        self.isEnabled = self.alarmSound != nil
        if self.alarmSound == nil || !self.alarmSound!.isPlaying {
            self.contentViewIndex = 0
        }
    }
    
    var isPlaying: Bool {
        return self.alarmSound?.isPlaying ?? false
    }
    
    func startPlaying() {
        if self.isPlaying {
            return
        }
   
        self.delegate?.playButtonSoundWillStart(self)
        
        if let alarmSound = self.alarmSound {
            self.delegate?.playButtonSoundDidStart(self)
            
            alarmSound.delegate = self
            alarmSound.play(withBehavior: self.alarmBehavior)

            self.refresh()
            
        } else {
            self.didStop()
        }
    }
    
    private func didStop() {
        if let alarmSound = self.alarmSound {
            alarmSound.stop()
            alarmSound.delegate = nil
        }
        self.timer.stop()
        self.delegate?.playButtonSoundDidStop(self)
        self.refresh()
    }
    
    func stopPlaying() {
        if !self.isPlaying {
            return
        }

        self.didStop()
    }
    
    func togglePlayingState() {
        if self.isPlaying {
            self.stopPlaying()
        } else {
            self.startPlaying()
        }
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
    
    func alarmSound(_ soundSetAlarmSound: SoundSetAlarmSound, willStartPlayingAlarmSound alarmSound:AlarmSound ) {
        self.delegate?.playButton(self, alarmSoundDidChange: self._alarmSound)
    }
    
    func alarmSound(_ soundSetAlarmSound: SoundSetAlarmSound, didStopPlayingAlarmSound alarmSound:AlarmSound ) {
        self.delegate?.playButton(self, alarmSoundDidChange: self._alarmSound)
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
        self.didStop()
    }
    
    var soundDisplayName: String? {
        if let alarmSound = self.alarmSound {
            return alarmSound.displayName
        }
        
        return nil
    }
}
