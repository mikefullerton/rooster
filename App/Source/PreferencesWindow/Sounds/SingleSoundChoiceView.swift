//
//  SoundChoiceView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import UIKit

protocol SoundChoiceViewDelegate : AnyObject {
    func soundChoiceViewChooser(_ view: SingleSoundChoiceView, buttonPressed button: UIButton)
}

class SingleSoundChoiceView : UIView {
    
    weak var delegate: SoundChoiceViewDelegate?

    let index: SoundPreference.SoundIndex
    
    let buttonHeight:CGFloat = 26
    
    init(frame: CGRect,
         soundPreferenceIndex index: SoundPreference.SoundIndex,
         delegate: SoundChoiceViewDelegate) {
        self.delegate = delegate
        self.index = index
        super.init(frame: frame)

        self.addSubview(self.checkbox)
        self.addSubview(self.pencilButton)
        self.addSubview(self.playButton)

        self.layout.addView(self.checkbox)
        self.layout.addView(self.pencilButton)
        self.layout.addView(self.playButton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: PreferencesController.DidChangeEvent, object: nil)

        self.refresh()
    }

    @objc func preferencesDidChange(_ sender: Notification) {
        self.refresh()
    }

    var sound: SoundPreference.Sound {
        get {
            return PreferencesController.instance.preferences.sounds[self.index]
        }
        set(newSound) {
            PreferencesController.instance.preferences.sounds[self.index] = newSound
        }
    }
    
    func setEnabledStates() {
        self.playButton.isEnabled = true
        self.pencilButton.isEnabled = true
    }
    
    @objc func checkboxChanged(_ sender: UISwitch) {
        var sound = self.sound
        sound.enabled = sender.isOn
        self.sound = sound
        
        self.setEnabledStates()
    }
    
    lazy var checkbox : UISwitch = {
        let view = UISwitch(frame: self.bounds)
        
        #if targetEnvironment(macCatalyst)
        view.preferredStyle = .checkbox
        #endif

        view.isOn = self.sound.enabled
        
        view.addTarget(self, action: #selector(checkboxChanged(_:)), for: .valueChanged)
        return view
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func editSound(_ sender: UIButton) {
        if let delegate = self.delegate {
            delegate.soundChoiceViewChooser(self, buttonPressed: sender)
        }
    }

    lazy var playButton: SoundPlayerButton = {
        let button = SoundPlayerButton()
        return button
    }()

    lazy var pencilButton: UIButton = {
        let button = UIButton.createImageButton(withImage: UIImage(systemName: "square.and.pencil"))
        button.imageView?.tintColor = UIColor.secondaryLabel
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 18), forImageIn: .normal)
        button.frame = CGRect(x: 0, y: 0, width: self.buttonHeight, height: self.buttonHeight)
        button.addTarget(self, action: #selector(editSound(_:)), for: .touchUpInside)
        return button
    }()

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: self.layout.intrinsicContentSize.height)
    }

    lazy var layout: HorizontallyOpposedLayout = {
        return HorizontallyOpposedLayout(hostView: self,
                                         insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                                         spacing: UIOffset(horizontal: 10, vertical: 0))
    }()

    func refresh() {
        let sound = self.sound
        if let newURL = sound.url {
            self.checkbox.title = sound.displayName
            self.checkbox.isOn = self.sound.enabled
            self.playButton.url = newURL
        
            self.setEnabledStates()
        } else {
            
            self.checkbox.title = "None"
            self.checkbox.isOn = false
            self.playButton.url = nil
            
            self.setEnabledStates()
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        self.layout.updateConstraints()
    }
 
    
}
