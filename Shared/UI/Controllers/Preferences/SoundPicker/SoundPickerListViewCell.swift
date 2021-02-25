//
//  SoundPickerListViewCell.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class SoundPickerListViewCell : ListViewRowController<SoundFile>, PlaySoundButtonSoundProvider {

    private var soundFile: SoundFile?
    private var soundPreferenceKey: SoundPreferences.SoundPreferenceKey = .sound1
    private var sound: Sound?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.wantsLayer = true
        
        self.addPlayButton()
        self.addTitleView()
    }
    
    override func viewWillAppear(withContent content: SoundFile) {
        self.soundFile = content
        self.sound = SoundFileSoundPlayer(withSoundFile: content, randomizer: RandomizationDescriptor.never)
        
        self.playButton.isEnabled = true
        
        if let fileName = self.soundFile?.displayName {
            self.titleView.stringValue = fileName
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.soundFile = nil
        self.sound = nil
    }

    override class var preferredHeight: CGFloat {
        return 32.0
    }
    
    func playSoundButtonProvideSound(_ playSoundButton: PlaySoundButton) -> Sound? {
        return self.sound
    }
    
    func playSoundButtonProvideSoundBehavior(_ playSoundButton: PlaySoundButton) -> SoundBehavior {
        return PlaySoundButton.defaultSoundBehavior
    }

    let buttonHeight:CGFloat = 20

    lazy var playButton: PlaySoundButton = {
        let button = PlaySoundButton()
        button.soundProvider = self
        
        return button
    }()

    lazy var titleView: SDKTextField = {
        let titleView = SDKTextField()
        titleView.isEditable = false
        titleView.textColor = Theme(for: self.view).secondaryLabelColor
        titleView.alignment = .left
        titleView.drawsBackground = false
        titleView.isBordered = false

        return titleView
    }()
    
    func addTitleView() {
        
        let titleView = self.titleView
        
        self.view.addSubview(titleView)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40),
            titleView.trailingAnchor.constraint(equalTo: self.playButton.leadingAnchor, constant: -20),
            titleView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
    }
    
    func addPlayButton() {
        let button = self.playButton
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)

        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
    }
    
    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set(selected) {
            super.isSelected = selected
            
            if selected {
                self.view.sdkBackgroundColor = SDKColor.systemBlue
            } else {
                self.view.sdkBackgroundColor = SDKColor.clear
            }
        }
    }
}
