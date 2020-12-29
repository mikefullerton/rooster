//
//  SoundChoicesView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import UIKit


protocol SoundChoicesViewDelegate : AnyObject {
    func soundChoicesView(_ view: SoundChoicesView,
                          presentSoundChooser soundChooser: SoundChooserViewController,
                          fromView: UIView)
}

class SoundChoicesView : GroupBoxView, SoundChoiceViewDelegate {
    
    weak var delegate: SoundChoicesViewDelegate?

    init(frame: CGRect, delegate: SoundChoicesViewDelegate) {
        self.delegate = delegate
        super.init(frame: frame,
                   title: "SOUNDS".localized)
        
        self.layout.addSubview(self.firstSoundChoice)
        self.layout.addSubview(self.secondSoundChoice)
        self.layout.addSubview(self.thirdSoundChoice)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var firstSoundChoice: UIView = {
        let view = SoundChoiceView(frame: self.bounds,
                                   soundPreferenceIndex: .sound1,
                                   delegate: self)
        
        return view
    }()

    lazy var secondSoundChoice: UIView = {
        let view = SoundChoiceView(frame: self.bounds,
                                   soundPreferenceIndex: .sound2,
                                   delegate: self)

        return view
    }()

    lazy var thirdSoundChoice: UIView = {
        let view = SoundChoiceView(frame: self.bounds,
                                   soundPreferenceIndex: .sound3,
                                   delegate: self)

        
        return view
    }()
    
    func soundChoiceViewChooser(_ view: SoundChoiceView, buttonPressed button: UIButton) {
        if let delegate = self.delegate {
            delegate.soundChoicesView(self,
                                      presentSoundChooser: SoundChooserViewController(withSoundPreferenceIndex: view.index),
                                      fromView: button)
        }
    }

}
