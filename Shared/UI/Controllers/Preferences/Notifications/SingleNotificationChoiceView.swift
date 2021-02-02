//
//  NotificationChoiceView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/27/20.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class AutomaticallyOpenLocationURLsChoiceView : SinglePreferenceChoiceView {
    
    
    init(frame: CGRect) {
        super.init(frame: frame,
                   title: "AUTO_OPEN_LOCATIONS".localized)
        
        self.addSubview(self.locationTipView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func addViewsToLayout() {
        self.layout.setViews([ self.checkbox,
                               self.locationTipView])
    }
    
    @objc override func checkboxChanged(_ sender: SDKButton) {

        var prefs = AppDelegate.instance.preferencesController.notificationPreferences
        
        if sender.intValue == 1 {
            prefs.options.insert(.autoOpenLocations)
        } else {
            prefs.options.remove(.autoOpenLocations)
        }
        
        AppDelegate.instance.preferencesController.notificationPreferences = prefs
    }
    
    override var value: Bool {
        return AppDelegate.instance.preferencesController.notificationPreferences.options.contains(.autoOpenLocations)
    }

    lazy var locationTipView : TipView = {
        
        var locationTip = Tip(image: SDKImage(systemSymbolName: "info.circle.fill", accessibilityDescription: "info.circle.fill"),
                              imageTintColor: SDKColor.systemBlue,
                              title: "SAFARI_TIP".localized,
                              action: nil)
        
        let view = TipView(frame: CGRect.zero, tip: locationTip)
        return view
    }()
}


class BounceInDockChoiceView : SinglePreferenceChoiceView {
    init(frame: CGRect) {
        super.init(frame: frame,
                   title: "BOUNCE_ICON".localized)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc override func checkboxChanged(_ sender: NSButton) {
        var prefs = AppDelegate.instance.preferencesController.notificationPreferences
        
        if sender.intValue == 1 {
            prefs.options.insert(.bounceAppIcon)
        } else {
            prefs.options.remove(.bounceAppIcon)
        }
        
        AppDelegate.instance.preferencesController.notificationPreferences = prefs
    }
    
    override var value: Bool {
        return AppDelegate.instance.preferencesController.notificationPreferences.options.contains(.bounceAppIcon)
    }
}


class UseSystemNotificationsChoiceView : SinglePreferenceChoiceView {

    init(frame: CGRect) {
        super.init(frame: frame,
                   title: "USE_SYSTEM_NOTIFICATIONS".localized)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc override func checkboxChanged(_ sender: NSButton) {
        var prefs = AppDelegate.instance.preferencesController.notificationPreferences
        
        if sender.intValue == 1 {
            prefs.options.insert(.useSystemNotifications)
        } else {
            prefs.options.remove(.useSystemNotifications)
        }
        
        AppDelegate.instance.preferencesController.notificationPreferences = prefs
    }

    override var value: Bool {
        return AppDelegate.instance.preferencesController.notificationPreferences.options.contains(.useSystemNotifications)
    }
    
}
