//
//  SoundChoicesView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import UIKit


protocol SoundChoicesViewDelegate : AnyObject {
    func soundChoicesViewPresentingViewController(_ view: SoundPreferencesView) -> UIViewController
}

class SoundPreferencesView : SimpleVerticalStackView, SoundChoiceViewDelegate, SoundChooserViewControllerDelegate {
    
    weak var delegate: SoundChoicesViewDelegate?

    init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setContainedViews([
            self.firstSoundChoice,
            self.secondSoundChoice,
            self.thirdSoundChoice,
            self.startDelayView,
            self.soundRepeatView,
            self.soundVolumeView
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var firstSoundChoice: SingleSoundChoiceView = {
        let view = SingleSoundChoiceView(frame: CGRect.zero,
                                         soundPreferenceIndex: .sound1,
                                         delegate: self)
        
        return view
    }()
    
    lazy var secondSoundChoice: SingleSoundChoiceView = {
        let view = SingleSoundChoiceView(frame: CGRect.zero,
                                         soundPreferenceIndex: .sound2,
                                         delegate: self)
        
        return view
    }()
    
    lazy var thirdSoundChoice: SingleSoundChoiceView = {
        let view = SingleSoundChoiceView(frame: CGRect.zero,
                                         soundPreferenceIndex: .sound3,
                                         delegate: self)

        
        return view
    }()
    
    
    let fixedLabelWidth: CGFloat = 100
    let sliderRightInset: CGFloat = 100
    
    lazy var soundVolumeView: LabeledSliderView = {
        var view = SoundVolumeView(  fixedLabelWidth: self.fixedLabelWidth,
                                     sliderRightInset: self.sliderRightInset)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var soundRepeatView: SoundRepeatView = {
        var view = SoundRepeatView(  fixedLabelWidth: self.fixedLabelWidth,
                                     sliderRightInset: self.sliderRightInset)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var startDelayView: StartDelayView = {
        var view = StartDelayView(  fixedLabelWidth: self.fixedLabelWidth,
                                     sliderRightInset: self.sliderRightInset)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    
    func soundChoiceViewChooser(_ view: SingleSoundChoiceView, buttonPressed button: UIButton) {
        if let delegate = self.delegate {
            let chooser = SoundPickerViewController(withSoundPreferenceIndex: view.index)
            chooser.delegate = self
            
            let presentingViewController = delegate.soundChoicesViewPresentingViewController(self)
            
            chooser.presentInViewController(presentingViewController, fromView: button)
        }
    }
    
    func soundChooserViewControllerWasDismissed(_ controller: SoundPickerViewController) {
    }
    
    func soundChooserViewControllerWillDismiss(_ controller: SoundPickerViewController) {
    }
}
