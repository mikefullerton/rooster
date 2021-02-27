//
//  SoundChoiceView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

protocol SingleSoundChoiceViewDelegate : AnyObject {
    func soundChoiceViewChooserEditSoundsButtonPressed(_ view: SingleSoundChoiceView)
}

class SingleSoundChoiceView : SDKView, PlaySoundButtonDelegate, PlaySoundButtonSoundProvider {
    
    weak var delegate: SingleSoundChoiceViewDelegate?

    let soundPreferenceKey: SoundPreferences.SoundPreferenceKey
    
    init(frame: CGRect,
         soundPreferenceKey: SoundPreferences.SoundPreferenceKey,
         delegate: SingleSoundChoiceViewDelegate) {
        self.delegate = delegate
        self.soundPreferenceKey = soundPreferenceKey
        
        super.init(frame: frame)

        self.addSubview(self.checkbox)
        self.addSubview(self.soundPickerButton)
        self.addSubview(self.playButton)
        self.addSubview(self.shuffleButton)

        self.needsUpdateConstraints = true

        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: PreferencesController.DidChangeEvent, object: nil)

        self.updatePlayList()
        self.refresh()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func preferencesDidChange(_ notification: Notification) {
        
        if  let oldPrefs = notification.oldPreferences,
            let newPrefs = notification.newPreferences {
            
            let oldSoundPrefs = oldPrefs.soundPreferences.soundPreference(forKey: self.soundPreferenceKey)
            
            let newSoundPrefs = newPrefs.soundPreferences.soundPreference(forKey: self.soundPreferenceKey)
                
            if oldSoundPrefs != newSoundPrefs {
                self.updatePlayList()
                self.refresh()
            }

        } else {
            self.updatePlayList()
            self.refresh()
        }
    }

    private var soundPreference: SingleSoundPreference {
        get {
            return Controllers.preferencesController.soundPreferences.soundPreference(forKey: self.soundPreferenceKey)
        }
        set(newPref) {
            Controllers.preferencesController.soundPreferences.setSoundPreference(newPref, forKey:self.soundPreferenceKey)
        }
    }
    
    private func setEnabledStates() {
        
        self.playButton.isEnabled = self.playList != nil && !self.playList!.isEmpty
        self.soundPickerButton.isEnabled = true
        self.checkbox.isEnabled = true
    }
    
    @objc private func checkboxChanged(_ sender: SDKSwitch) {
        
        var soundPref = self.soundPreference
        
        if sender.isOn {
            
            if soundPref.isSoundSetEmpty {
                if let delegate = self.delegate {
                    delegate.soundChoiceViewChooserEditSoundsButtonPressed(self)
                }
                return
            }
        }
        
        soundPref.isEnabled = sender.isOn
        self.soundPreference = soundPref
        
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

    @objc private func shuffleSounds(_ sender: SDKButton) {
        
        if self.soundPreference.isRandom {
            if let soundPlayer = self.playList?.currentSound {
                self.soundPreference = SingleSoundPreference.singleSoundPref(withSoundFiles: [soundPlayer.soundFile],
                                                                             randomizers: [soundPlayer.soundFile.id : PlayListRandomizer.never ] )
            } else {
                self.soundPreference = SingleSoundPreference.empty
            }

        } else {
            self.soundPreference = SingleSoundPreference.random
        }

        self.refresh()
    }
        
    func playSoundButton(_ playSoundButton: PlaySoundButton, willStartPlayingSound sound: Sound) {
        self.refresh()
    }

    func playSoundButton(_ playSoundButton: PlaySoundButton, didStartPlayingSound sound: Sound) {
        self.refresh()
    }
    
    func playSoundButton(_ playSoundButton: PlaySoundButton, didStopPlayingSound sound: Sound) {
        self.refresh()
    }
    
    func playSoundButton(_ playSoundButton: PlaySoundButton, soundDidUpdate sound: Sound) {
        self.refresh()
    }

    var playList: PlayList?
    
    func updatePlayList() {
        let soundPref = self.soundPreference
        let soundSet = soundPref.soundSet
        self.playList = soundSet.playList;
    }
    
    func playSoundButtonProvideSound(_ playSoundButton: PlaySoundButton) -> Sound? {
        return self.playList
    }
    
    func playSoundButtonProvideSoundBehavior(_ playSoundButton: PlaySoundButton) -> SoundBehavior {
        return SoundBehavior(playCount: 1, timeBetweenPlays: 0, fadeInTime: 0)
    }

    private lazy var playButton: PlaySoundButton = {
        let button = PlaySoundButton()
        button.delegate = self
        button.soundProvider = self
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
    
    func setShuffleButtonImage() {
        
        let config = NSImage.SymbolConfiguration(textStyle: .largeTitle)
        
        let soundPref = self.soundPreference
        if soundPref.isRandom {
            let image = NSImage(systemSymbolName: "shuffle.circle.fill", accessibilityDescription: "play")
            self.shuffleButton.image = image
            self.shuffleButton.toolTip = "Stop Shuffling Sounds"
        } else if soundPref.isSoundSetEmpty || !soundPref.isRandom {
            let image = NSImage(systemSymbolName: "shuffle.circle", accessibilityDescription: "play")
            
            self.shuffleButton.image = image
            self.shuffleButton.toolTip = "Shuffle Sounds"
        }
        
        self.shuffleButton.symbolConfiguration = config
        
    }
    
    private func refresh() {
        let soundPref = self.soundPreference
        self.checkbox.intValue = soundPref.isEnabled ? 1 : 0
        
        if let playList = self.playList,
            !playList.isEmpty {
            let soundName = playList.currentSoundDisplayName
            let playListName = playList.displayName
            
            if playListName.count > 0 {
                self.checkbox.title = "\(playListName): \(soundName)"
            } else {
                if soundPref.isRandom {
                    self.checkbox.title = "\(soundName) (random)"
                } else {
                    self.checkbox.title = soundName
                }
            }
        } else {
            if soundPref.isRandom {
                self.checkbox.title = "Random sound will be chosen when played".localized
            } else {
                self.checkbox.title = "NONE".localized
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
