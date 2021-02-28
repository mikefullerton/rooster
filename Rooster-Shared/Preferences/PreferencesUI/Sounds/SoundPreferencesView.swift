//
//  SoundChoicesView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif


protocol SoundPreferencesViewDelegate : AnyObject {
    func soundPreferencesView(_ view: SoundPreferencesView,
                              presentSoundPickerForSoundIndex soundPreferenceKey: SoundPreferences.PreferenceKey)
}

class SoundPreferencesView : SimpleStackView, SingleSoundChoiceViewDelegate {
    weak var delegate: SoundPreferencesViewDelegate?

    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    init(frame: CGRect) {
        
        super.init(frame: frame,
                   direction: .vertical,
                   insets: SDKEdgeInsets.ten,
                   spacing: SDKOffset.zero)
    
        let sounds = GroupBoxView(frame: CGRect.zero,
                                  title: "SOUND_CHOICE_EXPLANATION".localized,
                                  groupBoxInsets: GroupBoxView.defaultGroupBoxInsets,
                                  groupBoxSpacing: GroupBoxView.defaultGroupBoxSpacing)
        
        sounds.setContainedViews([
            self.firstSoundChoice,
            self.secondSoundChoice,
            self.thirdSoundChoice
        ])

        let repeatView = self.groupBoxView(forTitle: "SOUND_PLAYCOUNT_EXPLANATION".localized, view: self.soundRepeatView)

        let delay = self.groupBoxView(forTitle: "SOUND_DELAY_EXPLANATION".localized, view: self.startDelayView)
        
        let volume = self.groupBoxView(forTitle: "SOUND_VOLUME_EXPLANATION".localized, view: self.soundVolumeView)
        
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
    
    func groupBoxView(forTitle title: String, view containedView: SDKView) -> GroupBoxView {
        let view = GroupBoxView(frame: CGRect.zero,
                                title: title,
                                groupBoxInsets: SDKEdgeInsets(top:10, left: 0, bottom: 10, right: 0),
                                groupBoxSpacing: SDKOffset.zero)
        
        view.setContainedViews([ containedView ])
        
        return view
    }
    
    lazy var firstSoundChoice = SingleSoundChoiceView(frame: CGRect.zero,
                                                      soundPreferenceKey: .first,
                                                      delegate: self)
    
    lazy var secondSoundChoice = SingleSoundChoiceView(frame: CGRect.zero,
                                                       soundPreferenceKey: .second,
                                                       delegate: self)
    
    lazy var thirdSoundChoice = SingleSoundChoiceView(frame: CGRect.zero,
                                                      soundPreferenceKey: .third,
                                                      delegate: self)
    
    lazy var soundVolumeView = SoundVolumeView()
    
    lazy var soundRepeatView = SoundRepeatView()

    lazy var startDelayView = StartDelayView()

    func soundChoiceViewChooserEditSoundsButtonPressed(_ view: SingleSoundChoiceView) {
        if let delegate = self.delegate {
            delegate.soundPreferencesView(self,
                                          presentSoundPickerForSoundIndex: view.soundPreferenceKey)
        }
    }
}
