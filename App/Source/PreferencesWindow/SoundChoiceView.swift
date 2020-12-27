//
//  SoundChoiceView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import UIKit

class SoundChoiceView : UIView {
    
    let index:Int
    
    @objc func playSound(_ sender: UIButton) {
        print("Play sound: \(sender.tag)")
    }
    
    let buttonHeight:CGFloat = 22
    
    init(frame: CGRect, soundPreferenceIndex index: Int) {
        self.index = index
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var textField: UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.text = PreferencesController.instance.preferences.sounds.sound(withIndex: self.index)
        textField.isUserInteractionEnabled = false
        self.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: self.button.leadingAnchor),
            textField.topAnchor.constraint(equalTo: self.topAnchor),
            textField.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        return textField
    }()

    lazy var button: UIButton = {
        let button = UIButton.createImageButton(withImage: UIImage(systemName: "speaker.wave.2"))
            
        button.addTarget(self, action: #selector(playSound(_:)), for: .touchUpInside)
        button.tag = index
        
        self.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: self.buttonHeight),
            button.heightAnchor.constraint(equalToConstant: self.buttonHeight),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            button.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        return button
    }()
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var outSize = size
        outSize.height = self.textField.sizeThatFits(size).height
        return outSize
    }

    
}
