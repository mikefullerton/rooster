//
//  AppLauncher.swift
//  RoosterAutoLauncher
//
//  Created by Mike Fullerton on 4/15/21.
//

import AppKit
import Foundation

public enum SystemUtilities: Loggable {
    public static func bringAppToFront() {
        let result = NSRunningApplication.current.activate(options: .activateIgnoringOtherApps)

        self.logger.log("Attempted to bring app to front. Success: \(result)")
    }

    public static func findRunningApplication(for bundleIdentifier: String) -> [NSRunningApplication] {
        let apps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier)
        if !apps.isEmpty {
            return apps
        }

        for app in NSWorkspace.shared.runningApplications {
            let name = app.localizedName ?? ""
            if let bundleID = app.bundleIdentifier {
                if bundleIdentifier == bundleID {
                    self.logger.log("Found running app: \(name), bundle identifier: \(bundleID)")
                    return [ app ]
                }
            }
        }

        return []
    }

    public static func bringAnotherApp(toFront bundleIdentifier: String,
                                       completion:((_ success: Bool, _ error: Error?) -> Void)?) {
        self.logger.log("bringing app to front: \(bundleIdentifier)")

        let apps = self.findRunningApplication(for: bundleIdentifier)

        guard !apps.isEmpty else {
            self.logger.error("did not find any apps for bundleIdentifier: \(bundleIdentifier)")
            completion?(false, nil)
            return
        }

        for bundle in apps {
            bundle.unhide()

            let result = bundle.activate(options: .activateIgnoringOtherApps)
            self.logger.log("attempted to foreground: \(bundle): success: \(result)")
        }

        completion?(true, nil)
    }

    public static func launchApp(withBundleIdentifer bundleID: String,
                                 completion: ((_ success: Bool, _ runningApplication: NSRunningApplication?, _ error: Error?) -> Void)? = nil) {
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = runningApps.contains {
            $0.bundleIdentifier == bundleID
        }

        if !isRunning {
            guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
                self.logger.error("Unable to find app URL for \(bundleID)")
                return
            }

            let config = NSWorkspace.OpenConfiguration()
            config.promptsUserIfNeeded = false

            NSWorkspace.shared.openApplication(at: appURL,
                                               configuration: config) { runningApplication, error in
                guard runningApplication != nil, error == nil else {
                    self.logger.error("Unable to launch app at \(appURL.path) for bundleIdentifier: \(bundleID)")
                    completion?(false, nil, error)
                    return
                }

                self.logger.error("Launched \(appURL.path) for bundleIdentifier: \(bundleID) ok")
                completion?(true, runningApplication, error)
            }
        }
    }
}
