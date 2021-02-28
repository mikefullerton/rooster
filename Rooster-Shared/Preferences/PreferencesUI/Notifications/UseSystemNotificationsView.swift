//
//  UseSystemNotificationsView.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

class UseSystemNotificationsChoiceView : NotificationChoiceCheckboxView {

    init(withNotificationPreferenceKey prefsKey: NotificationPreferences.PreferenceKey) {
        super.init(withTitle: "USE_SYSTEM_NOTIFICATIONS".localized,
                   notificationPreferenceKey: prefsKey,
                   options: .useSystemNotifications)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // more to come
}
