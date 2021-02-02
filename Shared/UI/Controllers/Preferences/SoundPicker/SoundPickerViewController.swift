//
//  ModalSoundChooserViewController.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/30/20.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

protocol SoundPickerViewControllerDelegate : AnyObject {
    func soundPickerViewControllerWillDismiss(_ controller: SoundPickerViewController)
    func soundPickerViewControllerWasDismissed(_ controller: SoundPickerViewController)
}

class SoundPickerViewController : SDKViewController {
    
    weak var delegate: SoundPickerViewControllerDelegate?
    
    let soundPreferenceIndex: SoundPreferences.SoundIndex
    
    init(withSoundPreferenceIndex index: SoundPreferences.SoundIndex) {
        self.soundPreferenceIndex = index
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = SDKView()
        
        self.addSoundPicker()
        self.addBottomBar()

        self.title = "Sound Picker"
        
        self.preferredContentSize = CGSize(width: 500, height: 600)
    }
    
    lazy var bottomBar = BottomBar()
    
    lazy var soundPicker: SoundPickerTableViewController = {
        
        let soundPicker = SoundPickerTableViewController(withSoundIndex: self.soundPreferenceIndex)
        
        soundPicker.scrollView.contentInsets = SDKEdgeInsets(top: 0,
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
            AppDelegate.instance.preferencesController.soundPreferences[self.soundPreferenceIndex] = newSound
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
 
    override func viewDidLayout() {
        super.viewDidLayout()
    }
}

extension ModalWindowController {
    static func presentSoundPicker(withSoundPreference soundPreference: SoundPreferences.SoundIndex) {
        SoundPickerViewController(withSoundPreferenceIndex: soundPreference).presentInModalWindow()
    }
}
