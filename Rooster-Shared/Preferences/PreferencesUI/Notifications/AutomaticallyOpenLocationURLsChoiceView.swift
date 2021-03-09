//
//  NotificationChoiceView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/27/20.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class AutomaticallyOpenLocationURLsChoiceView : NotificationChoiceCheckboxView {
    
    init(withNotificationPreferenceKey prefsKey: NotificationPreferences.PreferenceKey) {
        super.init(withTitle: "AUTO_OPEN_LOCATIONS".localized,
                   notificationPreferenceKey: prefsKey,
                   options: .autoOpenLocations)
        
        self.addSubview(self.locationTipView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var locationTipView : TipView = {
        
        let image = SDKImage(systemSymbolName: "info.circle.fill", accessibilityDescription: "info.circle.fill")
        
        var locationTip = Tip(withImage: image,
                              imageTintColor: SDKColor.systemBlue,
                              title: "SAFARI_TIP".localized,
                              action: nil)
        
        let view = TipView(frame: CGRect.zero, tip: locationTip)
        return view
    }()
}


