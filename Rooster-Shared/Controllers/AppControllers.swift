//
//  AppControllers.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/15/21.
//

import Cocoa
import Foundation
import RoosterCore
import ServiceManagement

// swiftlint:disable implicitly_unwrapped_optional

public class AppControllers: Loggable {
    public static let shared = AppControllers()

    public let preferencesWindow = WindowOwner {
        let preferencesWindow = PreferencesWindow()
        preferencesWindow.show()
        return preferencesWindow
    }

    public let calendarWindow = WindowOwner {
        let windowController = WindowController()
        windowController.contentViewController = CalendarChooserViewController()
        windowController.autoSaveKey = NSWindowController.AutoSaveKey("Calendars", alwaysShow: true)
        windowController.show()
        return windowController
    }

    // MARK: - controllers
    public var appDelegate: AppDelegate {
        // swiftlint:disable force_cast
        NSApplication.shared.delegate as! AppDelegate
        // swiftlint:enable force_cast
    }
    public var preferences: PreferencesController!

    public let menuBar = MenuBarController()
    public let appIconController = AppIconController()
    public let hotKeysController = HotKeysController()
    public let sparkleController = SparkleController()
    public let mainWindowController = MainWindowController()
    public let errorController = ErrorController()
    public let developerMenuController = DeveloperMenuController()

    public let savedState = SavedState()

    // MARK: - private

    private var launchWindow: NSWindowController?
    private let preferencesUpdateHandler = PreferencesUpdateHandler()
}
// swiftlint:enable implicitly_unwrapped_optional

extension AppControllers {
    public func beginLaunching() {
        self.showLoadingWindow()

        var launchCoordinator: AppLaunchCoordinator? = AppLaunchCoordinator()

        launchCoordinator?.begin { [weak self] in
            self?.didFinishLaunching()

            launchCoordinator = nil
        }
    }

    private func didFinishLaunching() {
        CoreControllers.shared.open()

        self.startListeningForPrefChanges()

        self.restoreMainWindow()

        self.menuBar.showInMenuBar()
        self.sparkleController.configure(withAppBundle: Bundle(for: type(of: self.appDelegate)))
        self.developerMenuController.showDeveloperMenuIfNeeded()

        self.logger.log("finished loading all the data, opening main window")
    }

    public func quitRooster() {
        NSApp.terminate(self)
    }
}

extension AppControllers {
    func startListeningForPrefChanges() {
        self.updateAppStateWithPreferences(newPrefs: self.preferences.preferences, oldPrefs: nil)

        self.preferencesUpdateHandler.handler = { [weak self] newPrefs, oldPrefs in
            guard let self = self else { return }

            self.updateAppStateWithPreferences(newPrefs: newPrefs, oldPrefs: oldPrefs)

            CoreControllers.shared.scheduleController.reload { [weak self] success, _, error in
                guard let self = self else { return }

                guard success else {
                    self.logger.error("failed to reload schedule after prefs change: \(String(describing: error))")
                    return
                }
                self.logger.log("reload schedule ok after prefs change")
            }
        }
    }

    // swiftlint:disable cyclomatic_complexity

    func updateAppStateWithPreferences(newPrefs: Preferences, oldPrefs: Preferences?) {
        GlobalSoundVolume.volume = newPrefs.soundPreferences.volume

        self.setAutoLauncherEnabled(newPrefs: newPrefs, oldPrefs: oldPrefs)
        self.setShowInDock(newPrefs: newPrefs, oldPrefs: oldPrefs)

        var shortcuts: [(shortcut: KeyboardShortcut, handler: (_ shortcut: KeyboardShortcut) -> Void) ] = []

        for shortcut in newPrefs.keyboardShortcutPreferences.shortcuts {
            guard let id = KeyboardShortcut.KeyboardShortcutID(rawValue: shortcut.id) else {
                continue
            }

            guard shortcut.error == 0 else {
                continue
            }

            switch id {
            case .mainWindow:
                shortcuts.append((shortcut: shortcut, handler: { [weak self] _ in self?.showMainWindow() }))

            case .preferences:
                shortcuts.append((shortcut: shortcut, handler: { [weak self] _ in self?.showPreferencesWindow() }))

            case .calendars:
                shortcuts.append((shortcut: shortcut, handler: { [weak self] _ in self?.showCalendarsWindow() }))

            case .newReminder:
                // FUTURE
                break

            case .stopAlarms:
                shortcuts.append((shortcut: shortcut,
                                  handler: { _ in
                                    CoreControllers.shared.alarmNotificationController.stopAllNotifications(bringNotificationAppsForward: true)
                                  }))
            }
        }

        var allShortcuts = newPrefs.keyboardShortcutPreferences.shortcuts

        let results = self.hotKeysController.setKeyboadShortcuts(shortcuts)

        for i in 0..<allShortcuts.count {
            if let index = results.firstIndex(where: { $0.id == allShortcuts[i].id }) {
                allShortcuts[i].error = results[index].error
            }
        }

        if allShortcuts != newPrefs.keyboardShortcutPreferences.shortcuts {
            self.preferences.keyboardShortcut.shortcuts = allShortcuts
        }
    }

    func setAutoLauncherEnabled(newPrefs: Preferences, oldPrefs: Preferences?) {
        let automaticallyLaunch = newPrefs.general.automaticallyLaunch
        if let oldPrefs = oldPrefs,
           oldPrefs.general.automaticallyLaunch == automaticallyLaunch {
            return
        }

        let bundleID = "com.apple.commapps.rooster.autolauncher"
        let result = SMLoginItemSetEnabled(bundleID as CFString, automaticallyLaunch)

        if result {
            self.logger.log("set autoLaunch to \(automaticallyLaunch) ok")
        } else {
            self.logger.error("failed to update auto launcher setting")

            self.preferences.general.automaticallyLaunch = false
        }
    }

    public func setShowInDock(newPrefs: Preferences, oldPrefs: Preferences?) {
        let showInDock = newPrefs.general.showInDock

        let transformState = showInDock ?
            ProcessApplicationTransformState(kProcessTransformToForegroundApplication) :
            ProcessApplicationTransformState(kProcessTransformToUIElementApplication)

        // Show / hide dock icon.
        var psn = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: UInt32(kCurrentProcess))
        let transformStatus: OSStatus = TransformProcessType(&psn, transformState)

        self.logger.log("Result: \(transformStatus)")

        DispatchQueue.main.async {
            self.bringAppForward()
        }
    }

    func relaunchRooster() {
        let path = Bundle.main.bundlePath
        _ = Process.launchedProcess(launchPath: "/usr/bin/open",
                                    arguments: [path])
        self.quitRooster()
    }
}

extension AppControllers {
    func hideLaunchWindow() {
        if let launchWindow = self.launchWindow {
            launchWindow.close()
            self.launchWindow = nil
        }
    }

    func showLoadingWindow() {
        let window = LoadingWindowController()
        self.launchWindow = window
        window.showWindow(self)
    }

    public func showFirstRunWindow() {
        self.hideLaunchWindow()

        let window = FirstLaunchWindowController()
        self.launchWindow = window
        window.delegate = self
        window.showWindow(self)
    }

    public func restoreMainWindow() {
        self.hideLaunchWindow()
        if !self.mainWindowController.restoreVisibleState() {
            self.mainWindowController.showCenteredOnMainScreen()
        }
    }

    public func showPreferencesWindow() {
        NSApp.activate(ignoringOtherApps: true)
        self.preferencesWindow.show()
    }

    public func showCalendarsWindow() {
        NSApp.activate(ignoringOtherApps: true)
        self.calendarWindow.show()
    }

    public func showHelpWindow() {
        if let url = Self.infoUrl {
            NSWorkspace.shared.open(url,
                                    configuration: NSWorkspace.OpenConfiguration(),
                                    completionHandler: nil)
        }
    }

    public func showMainWindow() {
        self.bringAppForward()
        self.mainWindowController.showWindow(self)
    }

    public func toggleMainWindowVisibility() {
        self.bringAppForward()

        if self.mainWindowController.window?.isVisible ?? false {
            self.mainWindowController.close()
        } else {
            self.mainWindowController.showWindow(self)
        }
    }
}

extension AppControllers {
    private static var infoUrl: URL? = {
        if  let resourcePath = Bundle.main.resourceURL {
            return resourcePath.appendingPathComponent("About/about.html")
        }

        return nil
    }()
}

extension AppControllers: FirstLaunchWindowControllerDelegate {
    public func firstLaunchWindowControllerShouldDismiss(_ firstLaunchWindowController: FirstLaunchWindowController) {
        self.restoreMainWindow()
    }

    public func firstLaunchWindowControllerShowHelp(_ firstLaunchWindowController: FirstLaunchWindowController) {
        self.showHelpWindow()
    }

    public func firstLaunchWindowControllerShowSettings(_ firstLaunchWindowController: FirstLaunchWindowController) {
        self.preferencesWindow.show()
    }

    public func firstLaunchWindowControllerShowCalendars(_ firstLaunchWindowController: FirstLaunchWindowController) {
    }
}

extension AppControllers {
    public func bringAppForward() {
        NSApp.activate(ignoringOtherApps: true)
    }

    public func showRadarAlert() {
        NSApp.activate(ignoringOtherApps: true)

        let alert = NSAlert()
        alert.messageText = "Would you like to file a Radar?"
        alert.informativeText = "All bugs or suggestions are welcome!"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn {
            guard let url = URL(string: "rdar://new/problem/componentid=1188232") else {
                return
            }

            NSWorkspace.shared.open(url,
                                    configuration: NSWorkspace.OpenConfiguration(),
                                    completionHandler: nil)
        }
    }

    public func showCodeAlert() {
        NSApp.activate(ignoringOtherApps: true)

        let alert = NSAlert()
        alert.messageText = "Would you like to get involved in Rooster's development?"
        alert.informativeText = "Pull requests are wecome! \n\n(Contact mfullerton@apple.com if you don't have web access to code)"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Go To Code")
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn {
            guard let url = URL(string: "https://stashweb.sd.apple.com/users/mfullerton/repos/rooster") else {
                return
            }
            NSWorkspace.shared.open(url,
                                    configuration: NSWorkspace.OpenConfiguration(),
                                    completionHandler: nil)
        }
    }
}
