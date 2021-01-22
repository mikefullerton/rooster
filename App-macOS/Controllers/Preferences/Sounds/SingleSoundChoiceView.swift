//
//  SoundChoiceView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import Cocoa

protocol SoundChoiceViewDelegate : AnyObject {
    func soundChoiceViewChooser(_ view: SingleSoundChoiceView, buttonPressed button: NSButton)
}

class SingleSoundChoiceView : NSView {
    
    weak var delegate: SoundChoiceViewDelegate?

    let index: SoundPreference.SoundIndex
    
    init(frame: CGRect,
         soundPreferenceIndex index: SoundPreference.SoundIndex,
         delegate: SoundChoiceViewDelegate) {
        self.delegate = delegate
        self.index = index
        super.init(frame: frame)

        self.addSubview(self.checkbox)
        self.addSubview(self.soundPickerButton)
        self.addSubview(self.playButton)
        self.addSubview(self.shuffleButton)

        self.needsUpdateConstraints = true

        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: PreferencesController.DidChangeEvent, object: nil)

        self.refresh()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func preferencesDidChange(_ sender: Notification) {
        self.refresh()
    }

    private var sound: SoundPreference.Sound {
        get {
            return AppDelegate.instance.preferencesController.preferences.sounds[self.index]
        }
        set(newSound) {
            AppDelegate.instance.preferencesController.preferences.sounds[self.index] = newSound
        }
    }
    
    private func setEnabledStates() {
        self.playButton.isEnabled = true
        self.soundPickerButton.isEnabled = true
    }
    
    @objc private func checkboxChanged(_ sender: NSButton) {
        var sound = self.sound
        sound.enabled = sender.intValue == 1
        self.sound = sound
        
        self.setEnabledStates()
    }
    
    private lazy var checkbox : NSButton = {
        let view = NSButton(checkboxWithTitle: "", target: self, action: #selector(checkboxChanged(_:)))
        return view
    }()
    
    @objc private func editSound(_ sender: NSButton) {
        if let delegate = self.delegate {
            delegate.soundChoiceViewChooser(self, buttonPressed: sender)
        }
    }

    @objc private func shuffleSounds(_ sender: NSButton) {
        var sound = self.sound
        sound.enabled = true
        sound.random = true
        self.sound = sound
    }
    
    private lazy var playButton: PlaySoundButton = {
        let button = PlaySoundButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var soundPickerButton: NSButton = {
        
        guard let image = NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: "square.and.pencil") else {
            return NSButton()
        }
        
        let button = NSButton(image: image,
                              target: self,
                              action: #selector(editSound(_:)))
        button.isBordered = false
        button.contentTintColor = Theme(for: self).secondaryLabelColor
        button.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        return button
    }()

    private lazy var shuffleButton: NSButton = {

        guard let image = NSImage(systemSymbolName: "shuffle", accessibilityDescription: "shuffle") else {
            return NSButton()
        }

        let button = NSButton(image: image,
                              target: self,
                              action: #selector(shuffleSounds(_:)))
            
        button.isBordered = false
        button.contentTintColor = Theme(for: self).secondaryLabelColor
        button.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        return button
    }()

    override var intrinsicContentSize: CGSize {
        var outSize = CGSize(width: NSView.noIntrinsicMetric, height: self.checkbox.intrinsicContentSize.height)
        outSize.height += 10
        return outSize
    }

    func refresh() {
        let sound = self.sound
        if let newURL = sound.url {
            self.checkbox.title = sound.displayName
            self.checkbox.intValue = self.sound.enabled ? 1 : 0
            self.playButton.url = newURL
        
            self.setEnabledStates()
        } else {
            
            self.checkbox.title = "NONE".localized
            self.checkbox.intValue = 0
            self.playButton.url = nil
            
            self.setEnabledStates()
        }
        
        
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

//        self.invalidateIntrinsicContentSize()
    }
 
    
}
