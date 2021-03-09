//
//  SoundChoicesView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import UIKit

protocol SoundChoicesViewDelegate: AnyObject {
    func soundChoicesViewPresentingViewController(_ view: SoundPreferencesView) -> UIViewController
}

class SoundPreferencesView: SimpleStackView, SoundChoiceViewDelegate, SoundChooserViewControllerDelegate {
    weak var delegate: SoundChoicesViewDelegate?

    init(frame: CGRect) {
        super.init(frame: frame)

        let sounds = GroupBoxView(frame: CGRect.zero, title: "SOUND_CHOICE_EXPLANATION".localized)
        sounds.setContainedViews([
            self.firstSoundChoice,
            self.secondSoundChoice,
            self.thirdSoundChoice
        ])

        let repeatView = GroupBoxView(frame: CGRect.zero, title: "SOUND_PLAYCOUNT_EXPLANATION".localized)
        repeatView.setContainedViews([ self.self.soundRepeatView ])

        let delay = GroupBoxView(frame: CGRect.zero, title: "SOUND_DELAY_EXPLANATION".localized)
        delay.setContainedViews([ self.startDelayView ])

        let volume = GroupBoxView(frame: CGRect.zero, title: "SOUND_VOLUME_EXPLANATION".localized)
        volume.setContainedViews([ self.soundVolumeView ])

        self.setContainedViews([
            sounds,
            repeatView,
            delay,
            volume
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var firstSoundChoice: SingleSoundChoiceView = {
        let view = SingleSoundChoiceView(frame: CGRect.zero,
                                         soundPreferenceIndex: .first,
                                         delegate: self)

        return view
    }()

    lazy var secondSoundChoice: SingleSoundChoiceView = {
        let view = SingleSoundChoiceView(frame: CGRect.zero,
                                         soundPreferenceIndex: .second,
                                         delegate: self)

        return view
    }()

    lazy var thirdSoundChoice: SingleSoundChoiceView = {
        let view = SingleSoundChoiceView(frame: CGRect.zero,
                                         soundPreferenceIndex: .third,
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
