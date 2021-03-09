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
                                                      refresh: { self.pref.options.contains( .autoOpenLocations ) },
                                                      update: { self.pref.options.set(.autoOpenLocations, to: $0) })

        autoOpenPref.addSubview(self.locationTipView)

        notifs.setContainedViews([
            autoOpenPref,

            SinglePreferenceChoiceView(withTitle: "BOUNCE_ICON".localized,
                                       refresh: { self.pref.options.contains( .bounceAppIcon ) },
                                       update: { self.pref.options.set(.bounceAppIcon, to: $0) }),

            SinglePreferenceChoiceView(withTitle: "USE_SYSTEM_NOTIFICATIONS".localized,
                                       refresh: { self.pref.options.contains( .useSystemNotifications ) },
                                       update: { self.pref.options.set(.useSystemNotifications, to: $0) }),

            SinglePreferenceChoiceView(withTitle: "Play Sounds",
                                       refresh: { self.pref.options.contains( .playSounds ) },
                                       update: { self.pref.options.set(.playSounds, to: $0) })
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
