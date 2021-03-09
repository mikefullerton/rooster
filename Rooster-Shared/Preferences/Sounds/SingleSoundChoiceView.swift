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

public protocol SingleSoundChoiceViewDelegate: AnyObject {
    func soundChoiceViewChooserEditSoundsButtonPressed(_ view: SingleSoundChoiceView)
}

open class SingleSoundChoiceView: SDKView, PlaySoundButtonDelegate, PlaySoundButtonSoundProvider {
    weak var delegate: SingleSoundChoiceViewDelegate?

    var playList: PlayList

    let soundPreferenceKey: SoundPreferences.PreferenceKey

    private let preferencesUpdateHandler = PreferencesUpdateHandler()

    init(frame: CGRect,
         soundPreferenceKey: SoundPreferences.PreferenceKey,
         delegate: SingleSoundChoiceViewDelegate) {
        self.delegate = delegate
        self.soundPreferenceKey = soundPreferenceKey
        self.soundPreference = AppControllers.shared.preferences.soundPreferences.soundPreference(forKey: self.soundPreferenceKey)
        self.playList = PlayList()

        super.init(frame: frame)

        self.addSubview(self.checkbox)
        self.addSubview(self.soundPickerButton)
        self.addSubview(self.playButton)
        self.addSubview(self.shuffleButton)

        self.needsUpdateConstraints = true

        self.updatePlayList()
        self.refresh()

        self.preferencesUpdateHandler.handler = { [weak self] newPrefs, _ in
            guard let self = self else {
                return
            }

            let newSoundPrefs = newPrefs.soundPreferences.soundPreference(forKey: self.soundPreferenceKey)

            if self.soundPreference != newSoundPrefs {
                self.soundPreference = newSoundPrefs
                self.updatePlayList()
                self.refresh()
            }
        }
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var soundPreference: SingleSoundPreference {
        didSet {
            var soundPrefs = AppControllers.shared.preferences.soundPreferences
            soundPrefs.setSoundPreference(self.soundPreference, forKey: self.soundPreferenceKey)

            AppControllers.shared.preferences.soundPreferences = soundPrefs
        }
    }

    private func setEnabledStates() {
        self.playButton.isEnabled = !self.playList.isEmpty
        self.soundPickerButton.isEnabled = true
        self.checkbox.isEnabled = true
    }

    @objc private func checkboxChanged(_ sender: SDKSwitch) {
        var soundPref = self.soundPreference
        let soundSet = soundPref.soundSet

        if sender.isOn {
            if soundSet.isEmpty {
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

    private lazy var checkbox: SDKSwitch = {
        let view = SDKSwitch(title: "", target: self, action: #selector(checkboxChanged(_:)))
        view.toolTip = "Sound Title"
        return view
    }()

    @objc private func editSound(_ sender: SDKButton) {
        if let delegate = self.delegate {
            delegate.soundChoiceViewChooserEditSoundsButtonPressed(self)
        }
    }

    @objc private func shuffleSounds(_ sender: SDKButton) {
        if let currentSoundPlayer = self.playList.currentSoundPlayer {
            var soundFileCollection = SoundFileCollection()

            let soundRandomizer = self.playList.isRandom ?
                                        SoundPlayerRandomizer.default :
                                        SoundPlayerRandomizer(withBehavior: .replaceWithRandomSoundFromSoundFolder,
                                                              frequency: .normal)

            let playlistRandomizer = self.playList.isRandom ?
                                        PlayListRandomizer.default :
                                        PlayListRandomizer(withBehavior: .randomizeOrder)

            soundFileCollection.addSound(currentSoundPlayer.soundFile,
                                         randomizer: soundRandomizer)

            let soundSet = SoundSet(withID: String.guid,
                                    url: nil,
                                    displayName: "",
                                    randomizer: playlistRandomizer,
                                    soundFileCollection: soundFileCollection,
                                    soundFolder: SoundFolder.instance)

            let pref = SingleSoundPreference(withIdentifier: soundSet.id, soundSet: soundSet, enabled: true)

            self.soundPreference = pref
        } else {
            self.soundPreference = self.playList.isRandom ? SingleSoundPreference.empty : SingleSoundPreference.random
        }

        self.updatePlayList()
        self.refresh()
    }

    open func playSoundButton(_ playSoundButton: PlaySoundButton, willStartPlayingSound sound: SoundPlayerProtocol) {
        self.refresh()
    }

    open func playSoundButton(_ playSoundButton: PlaySoundButton, didStartPlayingSound sound: SoundPlayerProtocol) {
        self.refresh()
    }

    open func playSoundButton(_ playSoundButton: PlaySoundButton, didStopPlayingSound sound: SoundPlayerProtocol) {
        self.refresh()
    }

    open func playSoundButton(_ playSoundButton: PlaySoundButton, soundDidUpdate sound: SoundPlayerProtocol) {
        self.refresh()
    }

    func updatePlayList() {
        let soundPref = self.soundPreference
        let soundSet = soundPref.soundSet

        if soundSet.randomizer.behavior.contains( .randomizeOrder ) {
            soundSet.randomizer = PlayListRandomizer(withBehavior: [ .randomizeOrder, .regenerateEachPlay])
        }
        self.playList = PlayList(withSoundSet: soundSet)
    }

    public func playSoundButtonProvideSound(_ playSoundButton: PlaySoundButton) -> SoundPlayerProtocol? {
        self.playList
    }

    public func playSoundButtonProvideSoundBehavior(_ playSoundButton: PlaySoundButton) -> SoundBehavior {
        SoundBehavior(playCount: 1, timeBetweenPlays: 0, fadeInTime: 0)
    }

    private lazy var playButton: PlaySoundButton = {
        let button = PlaySoundButton()
        button.delegate = self
        button.soundProvider = self
        return button
    }()

    private lazy var shuffleButtonConfig = NSImage.SymbolConfiguration(scale: .large)

    private lazy var soundPickerButton: SDKButton = {
        let button = SDKButton(systemSymbolName: "square.and.pencil",
                               accessibilityDescription: "Choose Sound",
                               symbolConfiguration: self.shuffleButtonConfig,
                               target: self,
                               action: #selector(editSound(_:)))

        button.toolTip = "Choose Sound"
        //        button.symbolConfiguration = SDKImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        return button
    }()

    private lazy var shuffleButton: SDKButton = {
        let button = SDKButton(systemSymbolName: "shuffle.circle",
                               accessibilityDescription: "Choose Sound",
                               symbolConfiguration: self.shuffleButtonConfig,
                               target: self,
                               action: #selector(shuffleSounds(_:)))
        button.toolTip = "Randomize which sound is played"
        return button
    }()

    override open var intrinsicContentSize: CGSize {
        var outSize = CGSize(width: SDKView.noIntrinsicMetric, height: self.checkbox.intrinsicContentSize.height)
        outSize.height += 10
        return outSize
    }

    func setShuffleButtonImage() {
        let playList = self.playList

        if playList.isRandom {
            let image = NSImage.image(withSystemSymbolName: "shuffle.circle.fill",
                                      accessibilityDescription: "play",
                                      symbolConfiguration: self.shuffleButtonConfig)
            self.shuffleButton.image = image
            self.shuffleButton.toolTip = "Stop Shuffling Sounds"
        } else {
            let image = NSImage.image(withSystemSymbolName: "shuffle.circle",
                                      accessibilityDescription: "play",
                                      symbolConfiguration: self.shuffleButtonConfig)

            self.shuffleButton.image = image
            self.shuffleButton.toolTip = "Shuffle Sounds"
        }
    }

    private func refresh() {
        let soundPref = self.soundPreference

        self.checkbox.isOn = soundPref.isEnabled

        if !self.playList.isEmpty {
            let soundName = self.playList.currentSoundDisplayName
            let playListName = self.playList.displayName

            if !playListName.isEmpty {
                self.checkbox.title = "\(playListName): \(soundName)"
            } else {
                if self.playList.isRandom {
                    self.checkbox.title = "\(soundName) (Random Example)"
                } else {
                    self.checkbox.title = soundName
                }
            }
        } else {
            if self.playList.isRandom {
                self.checkbox.title = "Random sound will be chosen when played".localized
            } else {
                self.checkbox.title = "NONE".localized
            }
        }

        self.setShuffleButtonImage()
        self.setEnabledStates()
    }

    override open func updateConstraints() {
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
            self.soundPickerButton.trailingAnchor.constraint(equalTo: self.playButton.leadingAnchor, constant: -20),
            self.shuffleButton.trailingAnchor.constraint(equalTo: self.soundPickerButton.leadingAnchor, constant: -20),

            self.checkbox.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.checkbox.trailingAnchor.constraint(equalTo: self.shuffleButton.leadingAnchor, constant: -10)
        ])

        self.checkbox.setContentHuggingPriority(.defaultLow, for: .vertical)
        self.checkbox.setContentHuggingPriority(.defaultLow, for: .horizontal)

        self.checkbox.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        self.checkbox.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
}
