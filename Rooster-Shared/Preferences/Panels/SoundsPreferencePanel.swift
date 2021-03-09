//
//  SoundsPreferencePanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

public class SoundsPreferencePanel: PreferencePanel, SingleSoundChoiceViewDelegate {
    override public func loadView() {
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

    public func soundChoiceViewChooserEditSoundsButtonPressed(_ soundChoiceView: SingleSoundChoiceView) {
        guard let window = self.view.window else {
            return
        }

        let key = soundChoiceView.soundPreferenceKey
        let soundPicker = SoundPickerViewController(withSoundPreferenceKey: key)
        soundPicker.showInModalWindow(centeredOnWindow: window)
    }

    override public var buttonTitle: String {
        "Sounds"
    }

    override public var buttonImageTitle: String {
        "speaker.wave.3"
    }}
