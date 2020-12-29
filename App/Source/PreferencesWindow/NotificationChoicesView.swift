//
//  NotificationChoicesView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import UIKit

class NotificationChoicesView : GroupBoxView {
    
    init(frame: CGRect) {
        super.init(frame: frame,
                   title: "NOTIFICATIONS".localized )
        
        self.layout.addSubview(self.automaticallyOpenLocationURLs)
        self.layout.addSubview(self.bounceIconInDock)
        self.layout.addSubview(self.useSystemNotifications)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var automaticallyOpenLocationURLs : NotificationChoiceView = {
        return AutomaticallyOpenLocationURLsChoiceView(frame: self.bounds)
    }()

    lazy var bounceIconInDock : NotificationChoiceView = {
        return BounceInDockChoiceView(frame: self.bounds)
    }()

    lazy var useSystemNotifications : NotificationChoiceView = {
        return UseSystemNotificationsChoiceView(frame: self.bounds)
    }()
    
    
    
}

