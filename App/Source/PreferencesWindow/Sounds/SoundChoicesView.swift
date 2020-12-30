//
//  SoundChoicesView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import UIKit


protocol SoundChoicesViewDelegate : AnyObject {
    func soundChoicesViewPresentingViewController(_ view: SoundChoicesView) -> UIViewController
}

class SoundChoicesView : GroupBoxView, SoundChoiceViewDelegate, SoundChooserViewControllerDelegate {
    
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
    
    lazy var firstSoundChoice: SingleSoundChoiceView = {
        let view = SingleSoundChoiceView(frame: self.bounds,
                                   soundPreferenceIndex: .sound1,
                                   delegate: self)
        
        return view
    }()

    lazy var secondSoundChoice: SingleSoundChoiceView = {
        let view = SingleSoundChoiceView(frame: self.bounds,
                                   soundPreferenceIndex: .sound2,
                                   delegate: self)

        return view
    }()

    lazy var thirdSoundChoice: SingleSoundChoiceView = {
        let view = SingleSoundChoiceView(frame: self.bounds,
                                   soundPreferenceIndex: .sound3,
                                   delegate: self)

        
        return view
    }()
    
    func soundChoiceViewChooser(_ view: SingleSoundChoiceView, buttonPressed button: UIButton) {
        if let delegate = self.delegate {
            let chooser = ModalSoundChooserViewController(withSoundPreferenceIndex: view.index)
            chooser.delegate = self
            
            let presentingViewController = delegate.soundChoicesViewPresentingViewController(self)
            
            chooser.presentInViewController(presentingViewController, fromView: button)
        }
    }
    
    func soundChooserViewControllerWasDismissed(_ controller: SoundChooserViewController) {
    }
    
    func soundChooserViewControllerWillDismiss(_ controller: SoundChooserViewController) {
    }
}
