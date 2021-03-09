//
//  SoundsPreferencePanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

class SoundsPreferencePanel : PreferencePanel, SingleSoundChoiceViewDelegate {
    
    open override var toolbarButtonIdentifier: String {
        return "sounds"
    }

    public override func loadView() {
        
        let stackView = SimpleStackView(direction: .vertical,
                                        insets: SDKEdgeInsets.ten,
                                        spacing: SDKOffset.zero)
        self.view = stackView
        
        let sounds = GroupBoxView(title: "SOUND_CHOICE_EXPLANATION".localized)
        
        sounds.setContainedViews([
            SingleSoundChoiceView(frame: CGRect.zero,
                                  soundPreferenceKey: .first,
                                  delegate: self),
            SingleSoundChoiceView(frame: CGRect.zero,
                                  soundPreferenceKey: .second,
                                  delegate: self),
            SingleSoundChoiceView(frame: CGRect.zero,
                                  soundPreferenceKey: .third,
                                  delegate: self)
        ])
        
        stackView.setContainedViews([
            sounds,
            
            self.groupBoxView(forTitle: "SOUND_PLAYCOUNT_EXPLANATION".localized,
                              view: SoundRepeatView()),
            
            self.groupBoxView(forTitle: "SOUND_DELAY_EXPLANATION".localized,
                              view: StartDelayView()),
            
            self.groupBoxView(forTitle: "SOUND_VOLUME_EXPLANATION".localized,
                              view: SoundVolumeView())
        ])
        
    }
    
    func groupBoxView(forTitle title: String,
                      view containedView: SDKView) -> GroupBoxView {
        
        let view = GroupBoxView(title: title)
        
        view.setContainedViews([ containedView ])
        
        return view
    }
    

    func soundChoiceViewChooserEditSoundsButtonPressed(_ soundChoiceView: SingleSoundChoiceView) {
        SoundPickerViewController(withSoundPreferenceKey: soundChoiceView.soundPreferenceKey).presentInModalWindow(fromWindow: self.view.window)
    }
}
