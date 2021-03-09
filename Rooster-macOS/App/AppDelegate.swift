//
//  AppDelegate.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//
import Cocoa
import Foundation
import RoosterCore

public class Application: NSApplication, Loggable {
//    override func sendEvent(_ event: NSEvent) {
//        super.sendEvent(event)
//        
//        print("global event tracking: EventKitEvent: \(event)")
//    }
}

@main
public class AppDelegate: NSObject, NSApplicationDelegate, NSUserInterfaceValidations {
    public func applicationDidFinishLaunching(_ aNotification: Notification) {
        AppControllers.shared.beginLaunching()
    }

    @IBAction private func showHelp(_ sender: Any) {
        AppControllers.shared.showHelpWindow()
    }

    @IBAction private func fileRadar(_ sender: Any) {
        AppControllers.shared.showRadarAlert()
    }

    @IBAction private func showPreferences(_ sender: Any) {
        AppControllers.shared.showPreferencesWindow()
    }

    @IBAction private func openRepoURL(_ sender: Any) {
        AppControllers.shared.showCodeAlert()
    }

    @IBAction private func checkForUpdates(_ sender: Any) {
        AppControllers.shared.sparkleController.checkForUpdates()
    }

    @IBAction private func showCalendars(_ sender: Any) {
        AppControllers.shared.showCalendarsWindow()
    }

    @IBAction private func stopAllAlarms(_ sender: Any) {
        CoreControllers.shared.alarmNotificationController.stopAllNotifications(bringNotificationAppsForward: true)
    }

    @IBAction private func bringAppToFront(_ sender: Any) {
        NSApp.activate(ignoringOtherApps: true)
    }

    @IBAction private func quitRooster(_ sender: Any) {
        NSApp.terminate(self)
    }

    @IBAction private func showMainWindow(_ sender: Any) {
        AppControllers.shared.toggleMainWindowVisibility()
    }

    public func quitRooster() {
        NSApp.terminate(self)
    }

    public func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        let action = item.action

        if action == #selector(checkForUpdates(_:)) {
            return AppControllers.shared.sparkleController.canCheckForUpdates
        }

        return true
    }
}
