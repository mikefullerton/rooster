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

class NotificationChoicesView : SimpleStackView {
    
    let notificationPreferencesKey: NotificationPreferences.PreferenceKey
    
    init(withPreferencesKey prefKey: NotificationPreferences.PreferenceKey) {
        self.notificationPreferencesKey = prefKey
        
        super.init(direction: .vertical,
                   insets: SDKEdgeInsets.ten,
                   spacing: SDKOffset.zero)
        
        
        let notifs =  GroupBoxView(frame: CGRect.zero,
                                   title: self.blurb,
                                   groupBoxInsets: GroupBoxView.defaultGroupBoxInsets,
                                   groupBoxSpacing: SDKOffset(horizontal: 0, vertical: 14))
        
        notifs.setContainedViews([
            AutomaticallyOpenLocationURLsChoiceView(withNotificationPreferenceKey: self.notificationPreferencesKey),
            BounceInDockChoiceView(withNotificationPreferenceKey: self.notificationPreferencesKey),
            UseSystemNotificationsChoiceView(withNotificationPreferenceKey: self.notificationPreferencesKey),
            NotificationChoiceCheckboxView(withTitle: "Play Sounds", notificationPreferenceKey: self.notificationPreferencesKey, options: .playSounds)
        ])

        self.setContainedViews([
            notifs
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    lazy var blurb: String = {
        
        switch(self.notificationPreferencesKey) {
        case .cameraOrMicrophoneOn:
            return "What Rooster does when a meeting starts and your microphone or camera is on"
            
        case .machineLockedOrAsleep:
            return "What Rooster does when a meeting starts and your computer is locked or asleep"
            
        case .normal:
            return "What Rooster does when a meeting starts under normal circumstances"
        }
        
        
    }()
    
}

