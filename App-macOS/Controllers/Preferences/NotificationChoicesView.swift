//
//  NotificationChoicesView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import Cocoa

class NotificationChoicesView : SimpleVerticalStackView {
    
    init(frame: CGRect) {
        super.init(frame: frame,
                   insets: NSEdgeInsets.ten,
                   spacing: Offset.zero)
        
        let notifs =  GroupBoxView(frame: CGRect.zero,
                                   title: "NOTIFICATION_EXPLANATION".localized,
                                   groupBoxInsets: GroupBoxView.defaultGroupBoxInsets,
                                   groupBoxSpacing: Offset(horizontal: 0, vertical: 14))
        
        notifs.setContainedViews([
            self.automaticallyOpenLocationURLs,
            self.bounceIconInDock,
            self.useSystemNotifications
        ])

        self.setContainedViews([
            notifs
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var automaticallyOpenLocationURLs : SingleNotificationChoiceView = {
        return AutomaticallyOpenLocationURLsChoiceView(frame: self.bounds)
    }()

    lazy var bounceIconInDock : SingleNotificationChoiceView = {
        return BounceInDockChoiceView(frame: self.bounds)
    }()

    lazy var useSystemNotifications : SingleNotificationChoiceView = {
        return UseSystemNotificationsChoiceView(frame: self.bounds)
    }()
    
    
}

