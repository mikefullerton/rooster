//
//  NotificationsPreferencesPanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

public class NotificationsPreferencePanel: PreferencePanel {
    private lazy var tabViewController: VerticalTabViewController = {
        let controller = VerticalTabViewController()
        return controller
    }()

    override public func loadView() {
        self.view = SDKView()

        self.addChild(self.tabViewController)
        self.view.addSubview(self.tabViewController.view)

        self.view.setFillInParentConstraints(forSubview: self.tabViewController.view)

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
                            view: NotificationChoicesView(withPreferencesKey: .machineLockedOrAsleep))
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
                            view: NotificationChoicesView(withPreferencesKey: .machineLockedOrAsleep))
        ]
        #endif
        self.tabViewController.setItems(items, buttonListWidth: 240.0)
}

    override public var toolbarButtonIdentifier: String {
        "notifications"
    }
}
