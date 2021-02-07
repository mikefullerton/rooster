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

class SingleSoundChoiceView : SDKView, PlaySoundButtonDelegate {
    
    weak var delegate: SingleSoundChoiceViewDelegate?

    let soundPrefIndex: SoundPreferences.SoundIndex
    
    init(frame: CGRect,
         soundPreferenceIndex index: SoundPreferences.SoundIndex,
         delegate: SingleSoundChoiceViewDelegate) {
        self.delegate = delegate
        self.soundPrefIndex = index
        super.init(frame: frame)

        self.addSubview(self.checkbox)
        self.addSubview(self.soundPickerButton)
        self.addSubview(self.playButton)
        self.addSubview(self.shuffleButton)

        self.needsUpdateConstraints = true

        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: PreferencesController.DidChangeEvent, object: nil)

        self.updatePlayButton()
        self.refresh()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func preferencesDidChange(_ notification: Notification) {
        self.updatePlayButton()
        self.refresh()
    }

    private var soundPreference: SingleSoundPreference {
        get {
            return AppDelegate.instance.preferencesController.soundPreferences[self.soundPrefIndex]
        }
        set(newSound) {
            AppDelegate.instance.preferencesController.soundPreferences[self.soundPrefIndex] = newSound
        }
    }
    
    private func setEnabledStates() {
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
        
//        let soundPref = self.soundPreference
//        if soundPref.isRandom {
//
//            let soundIdentifier = SoundFileDescriptor(with: self.playButton.soundFile?.id ?? "",
//                                                  randomizerPriority: .never)
//
//            let soundSet = SoundSet(withIdentifier: "\(self.soundPrefIndex)",
//                                    name: "\(self.soundPrefIndex)",
//                                    soundIdentifiers: [ soundIdentifier ])
//
//            self.soundPreference = SingleSoundPreference(withIdentifier: "\(self.soundPrefIndex)",
//                                                         soundSet: soundSet,
//                                                         enabled: true)
//
//        } else {
//            self.soundPreference = SingleSoundPreference.random
//        }
//
//        self.refresh()
    }
    
    func makeSurePlayButtonHasSound() {
//        if self.playButton.
    }
    
    func playButtonSoundWillStart(_ playSoundButton: PlaySoundButton) {
        self.updatePlayButton()
        self.refresh()
    }
    
    func playButtonSoundDidStart(_ playSoundButton: PlaySoundButton) {
        self.refresh()
    }
    
    func playButtonSoundDidStop(_ playSoundButton: PlaySoundButton) {
        self.refresh()
    }

    func playButton(_ playSoundButton: PlaySoundButton, alarmSoundDidChange alarmSound: AlarmSound?) {
        self.refresh()
    }
    
    private func updatePlayButton() {
        let soundPref = self.soundPreference
        let soundSet = soundPref.soundSet
        self.playButton.alarmSound = soundSet.alarmSound;
    }

    private lazy var playButton: PlaySoundButton = {
        let button = PlaySoundButton()
        button.delegate = self
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
        
        if let soundDisplayName = self.playButton.soundDisplayName {
            self.checkbox.title = soundDisplayName
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
