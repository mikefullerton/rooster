//
//  BounceInDockChoiceView.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

class BounceInDockChoiceView : NotificationChoiceCheckboxView {
    
    init(withNotificationPreferenceKey prefsKey: NotificationPreferences.PreferenceKey) {
        super.init(withTitle: "BOUNCE_ICON".localized,
                   notificationPreferenceKey: prefsKey,
                   options:.bounceAppIcon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


