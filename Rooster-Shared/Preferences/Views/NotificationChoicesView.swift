//
//  NotificationChoicesView.swift
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

public class NotificationChoicesView: SimpleStackView {
    let notificationPreferencesKey: NotificationPreferences.PreferenceKey

    init(withPreferencesKey prefKey: NotificationPreferences.PreferenceKey) {
        self.notificationPreferencesKey = prefKey

        super.init(direction: .vertical,
                   insets: SDKEdgeInsets.ten,
                   spacing: SDKOffset.zero)

        let notifs = GroupBoxView(title: self.blurb)

        let autoOpenPref = SinglePreferenceChoiceView(withTitle: "AUTO_OPEN_LOCATIONS".localized,
                                                      updater: { view in view.checkbox.isOn = self.pref.options.contains( .autoOpenLocations ) },
                                                      setter: { view in self.pref.options.set(.autoOpenLocations, to: view.checkbox.isOn) })

        autoOpenPref.addSubview(self.locationTipView)

        notifs.setContainedViews([
            autoOpenPref,

            SinglePreferenceChoiceView(withTitle: "BOUNCE_ICON".localized,
                                       updater: { view in view.checkbox.isOn = self.pref.options.contains( .bounceAppIcon ) },
                                       setter: { view in self.pref.options.set(.bounceAppIcon, to: view.checkbox.isOn) }),

            SinglePreferenceChoiceView(withTitle: "USE_SYSTEM_NOTIFICATIONS".localized,
                                       updater: { view in view.checkbox.isOn = self.pref.options.contains( .useSystemNotifications ) },
                                       setter: { view in self.pref.options.set(.useSystemNotifications, to: view.checkbox.isOn) }),

            SinglePreferenceChoiceView(withTitle: "Play Sounds",
                                       updater: { view in view.checkbox.isOn = self.pref.options.contains( .playSounds ) },
                                       setter: { view in self.pref.options.set(.playSounds, to: view.checkbox.isOn) })
        ])

        self.setContainedViews([
            notifs
        ])
    }

    public var pref: SingleNotificationPreference {
        get {
            AppControllers.shared.preferences.notifications.preference(forKey: self.notificationPreferencesKey)
        }
        set(pref) {
            AppControllers.shared.preferences.notifications.setPreference(pref, forKey: self.notificationPreferencesKey)
        }
    }

    lazy var locationTipView: TipView = {
        let image = SDKImage(systemSymbolName: "info.circle.fill", accessibilityDescription: "info.circle.fill")

        var locationTip = Tip(withImage: image,
                              imageTintColor: SDKColor.systemBlue,
                              title: "SAFARI_TIP".localized,
                              action: nil)

        let view = TipView(frame: CGRect.zero, tip: locationTip)
        return view
    }()

//    @available(*, unavailable)
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    lazy var blurb: String = {
        switch self.notificationPreferencesKey {
        case .cameraOrMicrophoneOn:
            return "What Rooster does when a meeting starts and your microphone or camera is on"

        case .machineLockedOrAsleep:
            return "What Rooster does when a meeting starts and your computer is locked or asleep"

        case .normal:
            return "What Rooster does when a meeting starts under normal circumstances"
        }
    }()
}
