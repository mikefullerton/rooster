//
//  SoundChoiceView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import UIKit

protocol SoundChoiceViewDelegate : AnyObject {
    func soundChoiceViewChooser(_ view: SoundChoiceView, buttonPressed button: UIButton)
}

class SoundChoiceView : UIView {
    
    weak var delegate: SoundChoiceViewDelegate?

    let index: SoundPreference.SoundIndex
    
    let buttonHeight:CGFloat = 26
    
    init(frame: CGRect,
         soundPreferenceIndex index: SoundPreference.SoundIndex,
         delegate: SoundChoiceViewDelegate) {
        self.delegate = delegate
        self.index = index
        super.init(frame: frame)
        
        self.layout.addSubview(self.checkbox)
        self.layout.addSubview(self.playButton)
        self.layout.addSubview(self.pencilButton)
        
        self.setEnabledStates()
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
        self.playButton.isEnabled = self.sound.enabled
        self.pencilButton.isEnabled = self.sound.enabled
    }
    
    @objc func checkboxChanged(_ sender: UISwitch) {
        
        var sound = self.sound
        sound.enabled = sender.isOn
        self.sound = sound
        
        self.setEnabledStates()
    }
    
    lazy var checkbox : UISwitch = {
        let view = UISwitch(frame: self.bounds)
        view.title = self.sound.name
        
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
    
//    lazy var textField: UITextField = {
//        let textField = UITextField(frame: self.bounds)
//        textField.text = self.sound.name
//        textField.isUserInteractionEnabled = false
//        self.addSubview(textField)
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            textField.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//            textField.trailingAnchor.constraint(equalTo: self.button.leadingAnchor),
//            textField.topAnchor.constraint(equalTo: self.topAnchor),
//            textField.bottomAnchor.constraint(equalTo: self.bottomAnchor)
//        ])
//
//        return textField
//    }()

    @objc func playSound(_ sender: UIButton) {
        print("Play sound: \(self.sound)")
    }
    
    @objc func editSound(_ sender: UIButton) {
        if let delegate = self.delegate {
            delegate.soundChoiceViewChooser(self, buttonPressed: sender)
        }
    }

    lazy var playButton: UIButton = {
        let button = UIButton.createImageButton(withImage: UIImage(systemName: "speaker.wave.2"))
        button.frame = CGRect(x: 0, y: 0, width: self.buttonHeight, height: self.buttonHeight)
        button.addTarget(self, action: #selector(playSound(_:)), for: .touchUpInside)
        return button
    }()

    lazy var pencilButton: UIButton = {
        let button = UIButton.createImageButton(withImage: UIImage(systemName: "square.and.pencil"))
        button.frame = CGRect(x: 0, y: 0, width: self.buttonHeight, height: self.buttonHeight)
        button.addTarget(self, action: #selector(editSound(_:)), for: .touchUpInside)
        return button
    }()

    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var outSize = size
        outSize.height = self.layout.size.height
        return outSize
    }

    lazy var layout: ViewLayout = {
        return HorizontallyOpposedLayout(hostView: self,
                                         insets: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0),
                                         spacing: UIOffset(horizontal: 4, vertical: 0))
    }()

}
