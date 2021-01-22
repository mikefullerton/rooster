//
//  ModalSoundChooserViewController.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/30/20.
//

import Foundation
import Cocoa

protocol SoundChooserViewControllerDelegate : AnyObject {
    func soundChooserViewControllerWillDismiss(_ controller: SoundPickerViewController)
    func soundChooserViewControllerWasDismissed(_ controller: SoundPickerViewController)
}

class SoundPickerViewController : NSViewController {
    
    weak var delegate: SoundChooserViewControllerDelegate?
    
    let soundPreferenceIndex: SoundPreference.SoundIndex
    
    init(withSoundPreferenceIndex index: SoundPreference.SoundIndex) {
        self.soundPreferenceIndex = index
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = NSView()
    }
    
    lazy var topBar = TopBar(frame: self.view.bounds)
    lazy var bottomBar = BottomBar(frame: self.view.bounds)
    lazy var soundPicker = SoundPickerTableViewController(withSoundIndex: self.soundPreferenceIndex)
    
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
    
    @objc func doneButtonClicked(_ sender: NSButton) {
        if let newSound = self.soundPicker.chosenSound {
            AppDelegate.instance.preferencesController.preferences.sounds[self.soundPreferenceIndex] = newSound
        }
        
        self.presentingViewController?.dismiss(self)
        
//        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelButtonClicked(_ sender: NSButton) {
        self.presentingViewController?.dismiss(self)

//        self.dismiss(animated: true, completion: nil)
    }

    func addTopBar() {
        let topBar = self.topBar
        topBar.addToView(self.view)
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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addSoundPicker()
        self.addTopBar()
        self.addBottomBar()
        
        self.topBar.addTitleView(withText: "SOUND_PICKER".localized)
    }

    func presentInViewController(_ viewController: NSViewController, fromView view: NSView) {
        viewController.presentAsSheet(self)
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()

        let topHeight = self.topBar.frame.size.height
        
        if let scrollView = self.soundPicker.collectionView.enclosingScrollView {
        
            scrollView.contentInsets = NSEdgeInsets(top: topHeight,
                                                    left: 0,
                                                    bottom: self.bottomBar.frame.size.height,
                                                    right: 0)
            
            self.soundPicker.collectionView.scrollToItems(at: Set<IndexPath>([ IndexPath(item: 0, section: 0)]),
                                                          scrollPosition: .top)
        }

    }
}

