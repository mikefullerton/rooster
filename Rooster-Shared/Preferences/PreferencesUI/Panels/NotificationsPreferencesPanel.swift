//
//  NotificationsPreferencesPanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

class NotificationsPreferencePanel : VerticalTabViewController, VerticalTabViewControllerDelegate, PreferencePanel {
    
    func resetButtonPressed() {
        Controllers.preferencesController.preferences = Preferences.default
    }

    func verticalTabViewController(_ verticalTabViewController: VerticalTabViewController, didChangeTab tab: VerticalTabItem) {
//        self.bottomBar.leftButton.isEnabled = tab.identifier != "calendars"
    }
 
    
    override func loadView() {
        super.loadView()

        #if false
        let items = [
            VerticalTabItem(identifier: NotificationPreferences.PreferenceKey.normal.description,
                            title: NotificationPreferences.PreferenceKey.normal.description,
                            icon: SDKImage(systemSymbolName: "keyboard", accessibilityDescription: "normal use"),
                            view: NotificationChoicesView(withPreferencesKey: .normal)),
            VerticalTabItem(identifier: NotificationPreferences.PreferenceKey.cameraOrMicrophoneOn.description,
                            title: NotificationPreferences.PreferenceKey.cameraOrMicrophoneOn.description,
                            icon: SDKImage(systemSymbolName: "mic", accessibilityDescription: "microphone or camera"),
                            view: NotificationChoicesView(withPreferencesKey: .cameraOrMicrophoneOn)),
            
            
            VerticalTabItem(identifier: NotificationPreferences.PreferenceKey.machineLockedOrAsleep.description,
                            title: NotificationPreferences.PreferenceKey.machineLockedOrAsleep.description,
                            icon: SDKImage(systemSymbolName: "lock", accessibilityDescription: "lock"),
                            view: NotificationChoicesView(withPreferencesKey: .machineLockedOrAsleep)),
        ]
        #else
        let items = [
            VerticalTabItem(identifier: NotificationPreferences.PreferenceKey.normal.description,
                            title: NotificationPreferences.PreferenceKey.normal.description,
                            icon: SDKImage(systemSymbolName: "keyboard", accessibilityDescription: "normal use"),
                            view: NotificationChoicesView(withPreferencesKey: .normal)),

            VerticalTabItem(identifier: NotificationPreferences.PreferenceKey.machineLockedOrAsleep.description,
                            title: NotificationPreferences.PreferenceKey.machineLockedOrAsleep.description,
                            icon: SDKImage(systemSymbolName: "lock", accessibilityDescription: "lock"),
                            view: NotificationChoicesView(withPreferencesKey: .machineLockedOrAsleep)),
        ]
        #endif
        self.setItems(items, buttonListWidth: 240.0)

    }
    
    var toolbarButtonIdentifier: NSToolbarItem.Identifier {
        return NSToolbarItem.Identifier(rawValue: "notifications")
    }

}
