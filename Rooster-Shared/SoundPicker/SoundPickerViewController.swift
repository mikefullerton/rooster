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

protocol SoundPickerViewControllerDelegate : AnyObject {
    func soundPickerViewControllerWillDismiss(_ controller: SoundPickerViewController)
    func soundPickerViewControllerWasDismissed(_ controller: SoundPickerViewController)
}

class SoundPickerViewController : SDKViewController, QuickSearchViewDelegate, Loggable {
    
    weak var delegate: SoundPickerViewControllerDelegate?
    
    let soundPreferenceKey: SoundPreferences.SoundPreferenceKey
    
    
    init(withSoundPreferenceKey soundPreferenceKey: SoundPreferences.SoundPreferenceKey) {
        self.soundPreferenceKey = soundPreferenceKey
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = SDKView()
        
        self.addSoundPicker()
        self.addSearchView()
        self.addBottomBar()

        self.title = "Sound Picker"
        
        self.preferredContentSize = CGSize(width: 500, height: 600)
    }
    
    lazy var bottomBar = BottomBar()
    
    lazy var soundPicker: SoundPickerListViewController = {
        
        let soundPicker = SoundPickerListViewController(withSoundIndex: self.soundPreferenceKey)
        
        soundPicker.scrollView.contentInsets = SDKEdgeInsets(top: self.searchField.preferredHeight,
                                                            left: 0,
                                                            bottom: self.bottomBar.preferredHeight,
                                                            right: 0)
        return soundPicker
    } ()
    
    func addSoundPicker() {
        let soundPicker = self.soundPicker
        
        self.addChild(soundPicker)
        self.view.addSubview(soundPicker.view)
        
        soundPicker.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            soundPicker.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            soundPicker.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            soundPicker.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            soundPicker.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        
        
    }
    
    @objc func doneButtonClicked(_ sender: SDKButton) {
        if let newSound = self.soundPicker.chosenSound {
            Controllers.preferencesController.soundPreferences.setSoundPreference(newSound, forKey: self.soundPreferenceKey)
        }
        
        self.dismissWindow()
    }
    
    @objc func cancelButtonClicked(_ sender: SDKButton) {
        self.dismissWindow()
    }
    
    func addBottomBar() {
        let bottomBar = self.bottomBar
        bottomBar.doneButton.target = self
        bottomBar.doneButton.action = #selector(doneButtonClicked(_:))
        
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
    
    func quickSearchViewDidEndSearching(_ quickSearchView: QuickSearchView, content: String) {
        self.logger.log("Search ended with: \(content)")

        self.soundPicker.updateSoundFolder(SoundFolder.instance)
    }
    
    func quickSearchViewDidBeginSearching(_ quickSearchView: QuickSearchView, content: String) {
        
        self.logger.log("Got search string: \(content)")
        
        if content.count > 0 {
            if let soundFolder = SoundFolder.instance.findSubFolder(containing: content) {
                self.soundPicker.updateSoundFolder(soundFolder)
            } else {
                self.soundPicker.updateSoundFolder(SoundFolder.empty)
            }
        } else {
            self.soundPicker.updateSoundFolder(SoundFolder.instance)
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        
        self.searchField.becomeFirstResponder()
    }
}

extension ModalWindowController {
    static func presentSoundPicker(withSoundPreference soundPreference: SoundPreferences.SoundPreferenceKey) {
        SoundPickerViewController(withSoundPreferenceKey: soundPreference).presentInModalWindow()
    }
}
