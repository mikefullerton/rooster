//
//  AppControllers.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/15/21.
//

import Foundation
import RoosterCore

public class AppControllers: Loggable {
    public static let shared = AppControllers()

    // MARK: - controllers
    public var appDelegate: AppDelegate {
        // swiftlint:disable force_cast
        NSApplication.shared.delegate as! AppDelegate
        // swiftlint:enable force_cast
    }
    public let preferences = PreferencesController()
    public let menuBar = MenuBarController()
    public let appIconController = AppIconController()
    public let hotKeysController = HotKeysController()
    public let sparkleController = SparkleController()
    public let mainWindowController = MainWindowController()
    public let errorController = ErrorController()
    public let developerMenuController = DeveloperMenuController()

    // MARK: - private

    private var launchWindow: NSWindowController?
    private let preferencesUpdateHandler = PreferencesUpdateHandler()
}

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

        self.restoreMainWindow()

        self.menuBar.showInMenuBar()
        self.sparkleController.configure(withAppBundle: Bundle(for: type(of: self.appDelegate)))
        self.hotKeysController.addHotKeys()
        self.developerMenuController.showDeveloperMenuIfNeeded()

        self.preferencesUpdateHandler.handler = { newPrefs, _ in
            GlobalSoundVolume.volume = newPrefs.soundPreferences.volume
            CoreControllers.shared.scheduleController.reload { success, _, error in
                guard success else {
                    self.logger.error("failed to reload schedule after prefs change: \(String(describing: error))")
                    return
                }
                self.logger.log("reload schedule ok after prefs change")
            }
        }

        self.logger.log("finished loading all the data, opening main window")
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
        self.mainWindowController.restoreVisibleState()
    }

    private static var infoUrl: URL? = {
        if  let resourcePath = Bundle.main.resourceURL {
            return resourcePath.appendingPathComponent("About/about.html")
        }

        return nil
    }()

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

extension AppControllers: FirstLaunchWindowControllerDelegate {
    public func firstLaunchWindowControllerShouldDismiss(_ firstLaunchWindowController: FirstLaunchWindowController) {
        self.restoreMainWindow()
    }

    public func firstLaunchWindowControllerShowHelp(_ firstLaunchWindowController: FirstLaunchWindowController) {
        self.showHelpWindow()
    }

    public func firstLaunchWindowControllerShowSettings(_ firstLaunchWindowController: FirstLaunchWindowController) {
        PreferencesWindow.show()
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

    public func showPreferencesWindow() {
        NSApp.activate(ignoringOtherApps: true)
        PreferencesWindow.show()
    }

    public func showCalendarsWindow() {
        NSApp.activate(ignoringOtherApps: true)
        CalendarChooserViewController().presentInModalWindow(fromWindow: self.mainWindowController.window)
    }
}
