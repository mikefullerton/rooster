//
//  ModalSoundChooserViewController.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/30/20.
//

import Foundation
import UIKit

protocol SoundChooserViewControllerDelegate : AnyObject {
    func soundChooserViewControllerWillDismiss(_ controller: SoundPickerViewController)
    func soundChooserViewControllerWasDismissed(_ controller: SoundPickerViewController)
}

class SoundPickerViewController : UIViewController {
    
    weak var delegate: SoundChooserViewControllerDelegate?
    
    let soundPreferenceIndex: SoundPreferences.PreferenceKey
    
    init(withSoundPreferenceIndex index: SoundPreferences.PreferenceKey) {
        self.soundPreferenceIndex = index
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    @objc func doneButtonClicked(_ sender: UIButton) {
        if let newSound = self.soundPicker.chosenSound {
            Controllers.preferencesController.soundPreferences[self.soundPreferenceIndex] = newSound
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    func addTopBar() {
        let topBar = self.topBar
        topBar.addToView(self.view)
    }
    
    func addBottomBar() {
        let bottomBar = self.bottomBar
        bottomBar.doneButton.addTarget(self, action: #selector(doneButtonClicked(_:)), for: .touchUpInside)
        bottomBar.addCancelButton().addTarget(self, action: #selector(cancelButtonClicked(_:)), for: .touchUpInside)
        bottomBar.addToView(self.view)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addSoundPicker()
        self.addTopBar()
        self.addBottomBar()
        
        self.topBar.addTitleView(withText: "SOUND_PICKER".localized)
    }

    func presentInViewController(_ viewController: UIViewController, fromView view: UIView) {
        self.modalPresentationStyle = .pageSheet
        viewController.present(self, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let topHeight = self.topBar.frame.size.height
        
        self.soundPicker.tableView.contentInset = UIEdgeInsets(top: topHeight,
                                                               left: 0,
                                                               bottom: self.bottomBar.frame.size.height,
                                                               right: 0)
        
        self.soundPicker.tableView.contentOffset = CGPoint(x: 0, y: -topHeight)

    }
}

