//
//  AppDelegate.swift
//  RoosterAutoLauncher
//
//  Created by Mike Fullerton on 4/15/21.
//

import Cocoa
import OSLog

@main
public class AppDelegate: NSObject, NSApplicationDelegate {
    var roosterAppURL: URL? {
        var appURL = Bundle.main.bundleURL

        while appURL.lastPathComponent != "Rooster.app" {
            appURL = appURL.deletingLastPathComponent()

            guard appURL.path != "/" else {
                return nil
            }
        }

        return appURL
    }

    let roosterBundleID = "com.apple.commapps.rooster"

    var roosterIsRunning: Bool {
        NSWorkspace.shared.runningApplications.contains {
            $0.bundleIdentifier == self.roosterBundleID
        }
    }

    public func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.logger.info("Launching...")

        guard !self.roosterIsRunning else {
            self.logger.info("Rooster is already running")
            return
        }

        guard let appURL = self.roosterAppURL else {
            self.logger.error("Unable to find enclosing Rooster app")
            return
        }

        let config = NSWorkspace.OpenConfiguration()
        config.promptsUserIfNeeded = false

        NSWorkspace.shared.openApplication(at: appURL, configuration: config) { results, error in
            guard results != nil, error == nil else {
                self.logger.error("Unable to automatically launch Rooster at \(appURL.path)")
                return
            }

            self.logger.info("Launched \(appURL.path) for bundleIdentifier: \(self.roosterBundleID) ok")
        }
    }
}

extension AppDelegate {
    public static var subsystem: String {
        Bundle.main.bundleIdentifier ?? "nil"
    }

    public static var category: String {
        "\(type(of: self))".replacingOccurrences(of: ".Type", with: "")
    }

    public static var logger: Logger {
        Logger(subsystem: self.subsystem, category: self.category)
    }

    public var logger: Logger {
        Self.logger
    }
}
