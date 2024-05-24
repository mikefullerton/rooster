//
//  ModalSoundChooserViewController.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/30/20.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public protocol SoundPickerViewControllerDelegate: AnyObject {
    func soundPickerViewControllerWillDismiss(_ controller: SoundPickerViewController)
    func soundPickerViewControllerWasDismissed(_ controller: SoundPickerViewController)
}

public class SoundPickerViewController: SDKViewController,
                                        QuickSearchViewDelegate,
                                        Loggable,
                                        KeyViewProviding,
                                        PlaySoundButtonSoundProvider,
                                        SoundPickerListViewControllerDelegate, WindowConfigurator {
    public func willShow(inWindow window: NSWindow) {
        var styleMask = window.styleMask
        styleMask.insert(.resizable)
        window.styleMask = styleMask
        
        window.minSize = window.frame.size
        window.maxSize = NSSize(width: window.minSize.width * 2, height: window.minSize.width * 2)
    }
    
    weak var delegate: SoundPickerViewControllerDelegate?

    let soundPreferenceKey: SoundPreferences.PreferenceKey
    private var selectedSound: SoundFile?
    private var providedSound: SoundFile?

    init(withSoundPreferenceKey soundPreferenceKey: SoundPreferences.PreferenceKey) {
        self.soundPreferenceKey = soundPreferenceKey
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        self.view = SDKView()

        self.addSoundPicker()
        self.addSearchView()
        self.addBottomBar()

        self.title = "Sound Picker"

        self.preferredContentSize = CGSize(width: 400, height: 600)
    }

    override public var preferredContentSize: NSSize {
        didSet {
            self.soundPicker.preferredContentSize = self.preferredContentSize
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.soundPicker.collectionView.nextKeyView = self.searchField.searchField
        self.searchField.searchField.nextKeyView = self.soundPicker.collectionView
    }

    lazy var bottomBar = BottomBar()

    lazy var soundPicker: SoundPickerListViewController = {
        let soundPicker = SoundPickerListViewController(withSoundIndex: self.soundPreferenceKey)

        soundPicker.soundPickerDelegate = self

        soundPicker.scrollView?.contentInsets = SDKEdgeInsets(top: self.searchField.preferredHeight,
                                                              left: 0,
                                                              bottom: self.bottomBar.preferredHeight,
                                                              right: 0)
        return soundPicker
    }()

    func addSoundPicker() {
        let soundPicker = self.soundPicker

        self.addChild(soundPicker)
        self.view.addSubview(soundPicker.view)

        soundPicker.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            soundPicker.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            soundPicker.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)

//            soundPicker.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
//            soundPicker.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }

    @objc func doneButtonClicked(_ sender: SDKButton) {
        let newSounds = self.soundPicker.selectedSoundFiles
        if !newSounds.isEmpty {
            var soundFileCollection = SoundFileCollection()

            newSounds.forEach { soundFileCollection.addSound($0, randomizer: SoundPlayerRandomizer.default) }

            let soundSet = SoundSet(withID: String.guid,
                                    url: nil,
                                    displayName: "",
                                    randomizer: PlayListRandomizer.default,
                                    soundFileCollection: soundFileCollection,
                                    soundFolder: SoundFolder.instance)

            let pref = SingleSoundPreference(withIdentifier: soundSet.id, soundSet: soundSet, enabled: true)

            var soundPrefs = AppControllers.shared.preferences.soundPreferences
            soundPrefs.setSoundPreference(pref, forKey: self.soundPreferenceKey)
            AppControllers.shared.preferences.soundPreferences = soundPrefs
        }

        self.searchField.playSoundButton.stopPlaying()
        self.hideWindow()
    }

    @objc func cancelButtonClicked(_ sender: SDKButton) {
        self.searchField.playSoundButton.stopPlaying()
        self.hideWindow()
    }

    // swiftlint:disable private_action todo
    // TODO: make these private

    @IBAction public func playRandomSound(_ sender: SDKButton) {
        self.soundPicker.selectRandomSoundFile()
        self.playSound(self)
    }

    @IBAction public func playSound(_ sender: Any) {
        let wasPlaying = self.searchField.playSoundButton.isPlaying
        if wasPlaying {
            self.searchField.playSoundButton.stopPlaying()
        }

        if let selectedSound = self.selectedSound {
            if !wasPlaying ||
                (self.providedSound == nil || self.providedSound != selectedSound) {
                    self.searchField.playSoundButton.startPlaying()
            }
        }
    }

    @IBAction public func stopSound(_ sender: Any) {
        self.searchField.playSoundButton.stopPlaying()
    }

    // swiftlint:enable private_action todo

    @objc func performFindPanelAction(_ sender: Any) {
        self.searchField.becomeFirstResponder()
    }

    public func playSoundButtonProvideSound(_ playSoundButton: PlaySoundButton) -> SoundPlayerProtocol? {
        self.providedSound = self.selectedSound
        return self.providedSound?.soundPlayer
    }

    public func playSoundButtonProvideSoundBehavior(_ playSoundButton: PlaySoundButton) -> SoundBehavior {
        SoundBehavior()
    }

    public func soundPickerListViewControllerDidChangeSelection(_ controller: SoundPickerListViewController) {
        let sounds = self.soundPicker.selectedSoundFiles
        self.selectedSound = !sounds.isEmpty ? sounds[0] : nil
        self.searchField.playSoundButton.isEnabled = self.selectedSound != nil

        self.bottomBar.doneButton.isEnabled = self.selectedSound != nil
    }

    func addBottomBar() {
        let bottomBar = self.bottomBar
        bottomBar.doneButton.title = "Choose Sound"
        bottomBar.doneButton.target = self
        bottomBar.doneButton.action = #selector(doneButtonClicked(_:))
        bottomBar.doneButton.isEnabled = false

        let button = self.searchField.shuffleButton
        button.target = self
        button.action = #selector(playRandomSound(_:))

        let playSound = self.searchField.playSoundButton
        playSound.soundProvider = self
        playSound.isEnabled = false
        playSound.setTarget(self, action: #selector(playSound(_:)))

        let cancelButton = bottomBar.addCancelButton()
        cancelButton.target = self
        cancelButton.action = #selector(cancelButtonClicked(_:))
        bottomBar.addToView(self.view)
    }

    lazy var searchField: QuickSearchView = {
        let view = QuickSearchView()
        view.delegate = self
        return view
    }()

    func addSearchView() {
        let view = self.searchField
        view.addToView(self.view)
    }

    public func quickSearchViewDidEndSearching(_ quickSearchView: QuickSearchView, content: String) {
        self.logger.log("Search ended with: \(content)")

        self.soundPicker.updateSoundFolder(SoundFolder.instance)
    }

    public func quickSearchViewDidBeginSearching(_ quickSearchView: QuickSearchView, content: String) {
        self.logger.log("Got search string: \(content)")

        if !content.isEmpty {
            if let soundFolder = SoundFolder.instance.findSubFolder(containing: content) {
                self.soundPicker.updateSoundFolder(soundFolder)
            } else {
                self.soundPicker.updateSoundFolder(SoundFolder.empty)
            }
        } else {
            self.soundPicker.updateSoundFolder(SoundFolder.instance)
        }
    }

    public var initialKeyViewForWindow: NSView? {
        self.searchField.searchField
    }

    public func quickSearchViewDownArrowPressed(_ quickSearchView: QuickSearchView) {
        self.soundPicker.selectNextRow()
    }

    public func quickSearchViewUpArrowPressed(_ quickSearchView: QuickSearchView) {
        self.soundPicker.selectPreviousRow()
    }
}

extension ModalWindowController {
    static func presentSoundPicker(withSoundPreference soundPreference: SoundPreferences.PreferenceKey) {
        SoundPickerViewController(withSoundPreferenceKey: soundPreference).showInModalWindow()
    }
}
