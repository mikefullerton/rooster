//
//  SoundChoiceView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

protocol SingleSoundChoiceViewDelegate : AnyObject {
    func soundChoiceViewChooserEditSoundsButtonPressed(_ view: SingleSoundChoiceView)
}

class SingleSoundChoiceView : SDKView {
    
    weak var delegate: SingleSoundChoiceViewDelegate?

    let index: SoundPreferences.SoundIndex
    
    init(frame: CGRect,
         soundPreferenceIndex index: SoundPreferences.SoundIndex,
         delegate: SingleSoundChoiceViewDelegate) {
        self.delegate = delegate
        self.index = index
        super.init(frame: frame)

        self.addSubview(self.checkbox)
        self.addSubview(self.soundPickerButton)
        self.addSubview(self.playButton)
        self.addSubview(self.shuffleButton)

        self.needsUpdateConstraints = true

        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: PreferencesController.DidChangeEvent, object: nil)

        self.refresh()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func preferencesDidChange(_ sender: Notification) {
        self.refresh()
    }

    private var soundPreference: SingleSoundPreference {
        get {
            return AppDelegate.instance.preferencesController.soundPreferences[self.index]
        }
        set(newSound) {
            AppDelegate.instance.preferencesController.soundPreferences[self.index] = newSound
        }
    }
    
    private func setEnabledStates() {
        self.soundPickerButton.isEnabled = true
    }
    
    @objc private func checkboxChanged(_ sender: SDKSwitch) {
        
        if sender.isOn {
            let sound = self.soundPreference
            
            if sound.isEmpty {
                if let delegate = self.delegate {
                    delegate.soundChoiceViewChooserEditSoundsButtonPressed(self)
                }
                return
            }
        }
        
        var sound = self.soundPreference
        sound.isEnabled = sender.isOn
        self.soundPreference = sound
        
        self.setEnabledStates()
    }
    
    private lazy var checkbox : SDKSwitch = {
        let view = SDKSwitch(title: "", target: self, action: #selector(checkboxChanged(_:)), toolTip: "Sound Title")
        return view
    }()
    
    @objc private func editSound(_ sender: SDKButton) {
        if let delegate = self.delegate {
            delegate.soundChoiceViewChooserEditSoundsButtonPressed(self)
        }
    }

    private var dontShuffleNextSound = false
    
    @objc private func shuffleSounds(_ sender: SDKButton) {
        
        let soundPref = self.soundPreference
        if soundPref.isRandom {
            self.soundPreference = SingleSoundPreference(soundIdentifier: self.playButton.soundFile?.identifier ?? "", enabled: true)
            dontShuffleNextSound = false
        } else {
            self.soundPreference = SingleSoundPreference.random()
            dontShuffleNextSound = true
        }
        
        self.refresh()
    }
    
    @objc func playSound(_ sender: SDKButton) {
        if !self.playButton.isPlaying {
            if dontShuffleNextSound {
                dontShuffleNextSound = false
            } else {
                self.refresh()
            }
            self.playButton.startPlaying()
        } else {
            self.playButton.stopPlaying()
        }
    }
    
    private lazy var playButton: PlaySoundButton = {
        let button = PlaySoundButton()
        button.target = self
        button.action = #selector(playSound(_:))
        return button
    }()

    private lazy var soundPickerButton: SDKCustomButton = {
        let button = SDKCustomButton(systemImageName: "square.and.pencil",
                                     target: self,
                                     action: #selector(editSound(_:)),
                                     toolTip: "Choose Sound")
//        button.symbolConfiguration = SDKImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        return button
    }()

    
    
    private lazy var shuffleButton: SDKCustomButton = {
        
        let button = SDKCustomButton(systemImageName: "shuffle.circle",
                                     target: self,
                                     action: #selector(shuffleSounds(_:)),
                                     toolTip: "Randomize which sound is played")
        button.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        
//        button.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        return button
    }()

    override var intrinsicContentSize: CGSize {
        var outSize = CGSize(width: SDKView.noIntrinsicMetric, height: self.checkbox.intrinsicContentSize.height)
        outSize.height += 10
        return outSize
    }

    private func setNone() {
        self.checkbox.title = "NONE".localized
        self.checkbox.intValue = 0
        self.playButton.soundFile = nil
    }
    
    func setShuffleButtonImage() {
        
        let config = NSImage.SymbolConfiguration(textStyle: .largeTitle)
        
        let soundPref = self.soundPreference
        if soundPref.isRandom {
            let image = NSImage(systemSymbolName: "shuffle.circle.fill", accessibilityDescription: "play")
        
            self.shuffleButton.image = image
            
            self.shuffleButton.toolTip = "Stop Shuffling Sounds"
        } else if soundPref.isEmpty || !soundPref.isRandom {
            let image = NSImage(systemSymbolName: "shuffle.circle", accessibilityDescription: "play")
            
            self.shuffleButton.image = image
            self.shuffleButton.toolTip = "Shuffle Sounds"
        }
        
        self.shuffleButton.symbolConfiguration = config
        
    }
    
    func refresh() {
        let soundPref = self.soundPreference
        if soundPref.isEmpty {
            self.setNone()
        } else if soundPref.isRandom {
            let soundFile = SoundFolder.instance.randomSound
            self.checkbox.title = "\(soundFile.displayName) (Randomly Chosen)"
            self.checkbox.intValue = soundPref.isEnabled ? 1 : 0
            self.playButton.soundFile = soundFile
        } else {
            if let soundFile = SoundFolder.instance.findSound(forIdentifier: soundPref.soundIdentifier) {
                self.checkbox.title = soundFile.displayName
                self.checkbox.intValue = soundPref.isEnabled ? 1 : 0
                self.playButton.soundFile = soundFile
            } else {
                self.setNone()
            }
        }

        self.setShuffleButtonImage()
        self.setEnabledStates()
    
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        self.playButton.translatesAutoresizingMaskIntoConstraints = false
        self.soundPickerButton.translatesAutoresizingMaskIntoConstraints = false
        self.checkbox.translatesAutoresizingMaskIntoConstraints = false
        self.shuffleButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.playButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.soundPickerButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.checkbox.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.shuffleButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            self.playButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.soundPickerButton.trailingAnchor.constraint(equalTo: self.playButton.leadingAnchor, constant: -10),
            self.shuffleButton.trailingAnchor.constraint(equalTo: self.soundPickerButton.leadingAnchor, constant: -10),
            
            self.checkbox.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.checkbox.trailingAnchor.constraint(equalTo: self.shuffleButton.leadingAnchor, constant: -10)
        ])
    }
 
    
}
