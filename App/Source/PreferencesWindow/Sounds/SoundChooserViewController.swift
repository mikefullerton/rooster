//
//  ModalSoundChooserViewController.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/30/20.
//

import Foundation
import UIKit

protocol SoundChooserViewControllerDelegate : AnyObject {
    func soundChooserViewControllerWillDismiss(_ controller: SoundChooserViewController)
    func soundChooserViewControllerWasDismissed(_ controller: SoundChooserViewController)
}

class SoundChooserViewController : UIViewController {
    
    weak var delegate: SoundChooserViewControllerDelegate?
    
    let soundPreferenceIndex: SoundPreference.SoundIndex
    
    init(withSoundPreferenceIndex index: SoundPreference.SoundIndex) {
        self.soundPreferenceIndex = index
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var topBar = TopBar(frame: self.view.bounds, title: "Sound Picker")
    lazy var bottomBar = BottomBar(frame: self.view.bounds, withCancelButton: true)
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
        
        soundPicker.tableView.contentInset = UIEdgeInsets(top: self.topBar.frame.size.height,
                                                          left: 0,
                                                          bottom: self.bottomBar.frame.size.height,
                                                          right: 0)
        
    }
    
    @objc func doneButtonClicked(_ sender: UIButton) {
        self.soundPicker.setChosenSound()
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
        bottomBar.cancelButton.addTarget(self, action: #selector(cancelButtonClicked(_:)), for: .touchUpInside)
        bottomBar.addToView(self.view)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addSoundPicker()
        self.addTopBar()
        self.addBottomBar()
    }

    func presentInViewController(_ viewController: UIViewController, fromView view: UIView) {
        self.modalPresentationStyle = .pageSheet
        viewController.present(self, animated: true, completion: nil)
    }
}

