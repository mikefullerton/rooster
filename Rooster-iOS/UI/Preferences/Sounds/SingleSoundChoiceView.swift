//
//  SoundChoiceView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import UIKit

protocol SingleSoundChoiceViewDelegate: AnyObject {
    func soundChoiceViewChooser(_ view: SingleSoundChoiceView, buttonPressed button: UIButton)
}

class SingleSoundChoiceView: UIView {
    weak var delegate: SoundChoiceViewDelegate?

    let index: SoundPreferences.PreferenceKey

    let preferencesUpdateHandler = PreferencesEventListener()

    init(frame: CGRect,
         soundPreferenceIndex index: SoundPreferences.PreferenceKey,
         delegate: SoundChoiceViewDelegate) {
        self.delegate = delegate
        self.index = index
        super.init(frame: frame)

        self.addSubview(self.checkbox)
        self.addSubview(self.soundPickerButton)
        self.addSubview(self.playButton)
        self.addSubview(self.shuffleButton)

        self.setNeedsUpdateConstraints()

        NotificationCenter.default.addObserver(self, selector: #selector(e(_:)), name: PreferencesController.DidChangeEvent, object: nil)

        self.preferencesUpdateHandler.handler = { [weak self] _, _ in
           guard let self = self else { return }

           self.refresh()
        }

        self.refresh()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var sound: SingleSoundPreference {
        get {
            AppControllers.shared.preferences.soundPreferences[self.index]
        }
        set(newSound) {
            AppControllers.shared.preferences.soundPreferences[self.index] = newSound
        }
    }

    private func setEnabledStates() {
        self.playButton.isEnabled = true
        self.soundPickerButton.isEnabled = true
    }

    @objc private func checkboxChanged(_ sender: UISwitch) {
        var sound = self.sound
        sound.enabled = sender.isOn
        self.sound = sound

        self.setEnabledStates()
    }

    private lazy var checkbox: UISwitch = {
        let view = UISwitch(frame: self.bounds)
        view.translatesAutoresizingMaskIntoConstraints = false

        #if targetEnvironment(macCatalyst)
        view.preferredStyle = .checkbox
        #endif

        view.isOn = self.sound.enabled
        view.addTarget(self, action: #selector(checkboxChanged(_:)), for: .valueChanged)
        return view
    }()

    @objc private func editSound(_ sender: UIButton) {
        if let delegate = self.delegate {
            delegate.soundChoiceViewChooser(self, buttonPressed: sender)
        }
    }

    @objc private func shuffleSounds(_ sender: UIButton) {
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

    private lazy var soundPickerButton: UIButton = {
        let button = UIButton.createImageButton(withImage: UIImage(systemName: "square.and.pencil"))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.tintColor = Theme(for: self).secondaryLabelColor
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 18), forImageIn: .normal)
        button.addTarget(self, action: #selector(editSound(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var shuffleButton: UIButton = {
        let button = UIButton.createImageButton(withImage: UIImage(systemName: "shuffle"))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.tintColor = Theme(for: self).secondaryLabelColor
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 16), forImageIn: .normal)
        button.addTarget(self, action: #selector(shuffleSounds(_:)), for: .touchUpInside)
        return button
    }()

    override var intrinsicContentSize: CGSize {
        var outSize = CGSize(width: UIView.noIntrinsicMetric, height: self.checkbox.intrinsicContentSize.height)
        outSize.height += 10
        return outSize
    }

    func refresh() {
        let sound = self.sound
        if let newURL = sound.url {
            self.checkbox.title = sound.displayName
            self.checkbox.isOn = self.sound.enabled
            self.playButton.url = newURL

            self.setEnabledStates()
        } else {
            self.checkbox.title = "NONE".localized
            self.checkbox.isOn = false
            self.playButton.url = nil

            self.setEnabledStates()
        }
    }

    override func updateConstraints() {
        super.updateConstraints()

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

        self.invalidateIntrinsicContentSize()
    }
}
