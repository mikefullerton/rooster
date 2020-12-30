//
//  SoundPickerTableViewCell.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
import UIKit

protocol SoundPickerTableViewCellDelegate : AnyObject {
    func soundPickerTableViewCell(_ soundPicker: SoundPickerTableViewCell, didSelectSound soundURL: URL)
}

class SoundPickerTableViewCell : UITableViewCell, TableViewRowCell, AlarmSoundDelegate {
    
    weak var soundPickerDelegate: SoundPickerTableViewCellDelegate?
    
    func soundWillStartPlaying(_ sound: AlarmSound) {
    
    }
    
    func soundDidStopPlaying(_ sound: AlarmSound) {
    
    }
    
    private var url: URL?
    private var soundIndex: SoundPreference.SoundIndex = .sound1
    
    private var sound: AVAlarmSound?
    
    var soundPref: SoundPreference.Sound {
        get {
            return PreferencesController.instance.preferences.sounds[self.soundIndex]
        }
        set(newSound) {
            PreferencesController.instance.preferences.sounds[self.soundIndex] = newSound
        }
    }
    
    func setURL(_ url: URL, soundIndex: SoundPreference.SoundIndex) {
        self.url = url
        self.playButton.url = url
        self.playButton.isEnabled = true
        
        if let fileName = self.url?.fileName {
            self.titleView.text = fileName
            self.soundIndex = soundIndex
            self.checkMark.isHidden = fileName != self.soundPref.name
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.url = nil
        self.sound = nil
    }
    
    static var cellHeight: CGFloat {
        return 32.0
    }
    
    let buttonHeight:CGFloat = 20
    
    @objc func wasTapped(_ sender: UITapGestureRecognizer) {
        let touch = sender.location(in: self.contentView)

        if !self.checkMark.frame.contains(touch) && !self.titleView.frame.contains(touch) {
            return
        }
        
        if let url = self.url {
            var soundPref = self.soundPref
            soundPref.url = url
            self.soundPref = soundPref
            
            if let delegate = self.soundPickerDelegate {
                delegate.soundPickerTableViewCell(self, didSelectSound: url)
            }
        }
    }
    
    lazy var gestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(wasTapped(_:)))
    }()
    
    lazy var titleView: UITextField = {
        let titleView = UITextField()
        titleView.isUserInteractionEnabled = false
        titleView.textColor = UIColor.secondaryLabel
        titleView.textAlignment = .left
        
        self.contentView.addSubview(titleView)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: self.checkMark.trailingAnchor, constant: 10),
            titleView.trailingAnchor.constraint(equalTo: self.playButton.leadingAnchor, constant: 0),
            titleView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            titleView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])

        self.contentView.addGestureRecognizer(self.gestureRecognizer)
        
        return titleView
    }()
    
    lazy var playButton: SoundPlayerButton = {
        
        let button = SoundPlayerButton()

        self.contentView.addSubview(button)

        button.frame = CGRect(x: 0, y: 0, width: self.buttonHeight, height: self.buttonHeight)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
            button.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),

            button.widthAnchor.constraint(equalToConstant: button.frame.size.width),
            button.heightAnchor.constraint(equalToConstant: button.frame.size.height)
        ])

        return button
    }()

    lazy var checkMark: UIView = {
        let button = UIImageView(image: UIImage(systemName: "checkmark"))
        button.tintColor = UIColor.label
        
        self.contentView.addSubview(button)
        
        button.frame = CGRect(x: 0, y: 0, width: 16, height: 16)

        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
            button.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),

            button.widthAnchor.constraint(equalToConstant: button.frame.size.width),
            button.heightAnchor.constraint(equalToConstant: button.frame.size.height)
        ])

        return button
    }()

}
