//
//  ModalSoundChooserViewController.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/30/20.
//

import Foundation
import UIKit

class ModalSoundChooserViewController : UIViewController, SoundPickerTableViewControllerDelegate, SoundChooserViewController {
    
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
        soundPicker.soundPickerDelegate = self
        
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
        self.dismiss(animated: true, completion: nil)
    }

//    lazy var layout = TopBottomBarVerticalLayout(hostView: self.view,
//                                                 insets: UIEdgeInsets.zero,
//                                                 spacing: UIOffset.zero)
//

    
    func addTopBar() {
        let topBar = self.topBar
        topBar.addToView(self.view)
    }
    
    func addBottomBar() {
        let bottomBar = self.bottomBar
        bottomBar.doneButton.addTarget(self, action: #selector(doneButtonClicked(_:)), for: .touchUpInside)
        bottomBar.addToView(self.view)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addSoundPicker()
        self.addTopBar()
        self.addBottomBar()
    }

    func soundPickerTableViewController(_ soundPicker: SoundPickerTableViewController, didSelectSound soundURL: URL) {
//        self.animateOff()
    }
    
    func presentInViewController(_ viewController: UIViewController, fromView view: UIView) {
        
        self.modalPresentationStyle = .pageSheet
        viewController.present(self, animated: true, completion: nil)
        
        
//        viewController.addChild(self)
//        viewController.view.addSubview(self.view)
//
//        self.view.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            self.view.topAnchor.constraint(equalTo: viewController.view.topAnchor),
//            self.view.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
//            self.view.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
//            self.view.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor)
//        ])
//
//        viewController.view.setNeedsLayout()
    }



}

