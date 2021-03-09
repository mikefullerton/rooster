//
//  SparkleSupport.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/19/20.
//

import Foundation
import Sparkle

@objc public class SparkleController: NSObject, SUUpdaterDelegate, Loggable, SparkleTimerDelegate {
//    public weak var delegate: AppKitInstallationUpdaterDelegate?

    private var updater: SUUpdater?
    private var error: Error?
    private var showErrorDialog = false

    let timer = SparkleTimer(withDelegate: self)

    func checkForUpdatesIfNeeded() {
        self.timer.stop()
        self.logger.log("Starting to check if check for new update is needed")
        DispatchQueue.main.async {
            if let updater = self.updater {
                if !updater.updateInProgress {
                    if self.timer.isTimeForUpdate {
                        self.logger.log("Starting check for updates in the backgound on feed: \(updater.feedURL)")
                        updater.checkForUpdatesInBackground()
                    } else {
                        self.logger.log("Not checking for updates yet")
                        self.timer.startNextCheckTimer()
                    }
                } else {
                    self.logger.log("Update in progress, not checking")
                    self.timer.startNextCheckTimer()
                }
            }
        }
    }

    func sparkleTimerCheckForUpdates(_ timer: SparkleTimer) {
        self.checkForUpdatesIfNeeded()
    }

    @objc func appDidBecomeActiveNotification(_ sender: Notification) {
        self.checkForUpdatesIfNeeded()
    }

    public func configure(withAppBundle appBundle: Bundle) {
        if let updater = SUUpdater(for: appBundle) {
            updater.delegate = self
            updater.sendsSystemProfile = false
            updater.automaticallyChecksForUpdates = false // this updates its check date if it fails. Dumb.
            updater.automaticallyDownloadsUpdates = true
            self.updater = updater
            self.logger.log("Sparkle updater configured. Last update check was: \(self.timer.lastUpdateCheckDate?.description ?? "None" )")

            self.checkForUpdatesIfNeeded()

            NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActiveNotification(_:)), name: NSApplication.didBecomeActiveNotification, object: nil)
        } else {
            self.logger.error("Failed to create Sparkle updater")
        }
    }

    public func checkForUpdates() {
        self.logger.log("User requested update check")
        self.timer.stop()
        if let updater = self.updater {
            updater.checkForUpdates(self)
        }
    }

    public func updaterDidNotFindUpdate(_ updater: SUUpdater) {
        self.logger.log("Sparkle did not find update")
        self.timer.didSuccessfullyCheck()
    }

    public func updater(_ updater: SUUpdater, didFindValidUpdate item: SUAppcastItem) {
        self.logger.log("Sparkle did find valid update (will automatically download)")
        self.timer.didSuccessfullyCheck()
    }

//    public func updaterShouldPromptForPermissionToCheck(forUpdates updater: SUUpdater) -> Bool {
//        self.logger.log("Sparkle asked for permission to check")
//        return true
//    }

    public func showErrorAlert() {
        if self.showErrorDialog {
            self.showErrorDialog = false

            let alert = NSAlert()
            alert.messageText = NSLocalizedString("UPDATING_FAILED", bundle: Bundle(for: type(of: self)), comment: "")
            alert.informativeText = NSLocalizedString("CONFIRM_INTERNAL_NETWORK", bundle: Bundle(for: type(of: self)), comment: "")
            alert.alertStyle = NSAlert.Style.informational
            alert.addButton(withTitle: NSLocalizedString("OK", bundle: Bundle(for: type(of: self)), comment: ""))
            _ = alert.runModal()
        }
    }

    public func updater(_ updater: SUUpdater, didAbortWithError error: Error) {
        self.logger.error("Sparkle did abort with error: \(String(describing: error))")
        if let nsError = error as NSError? {
            if nsError.domain == SUSparkleErrorDomain && nsError.code == SUError.appcastError.rawValue {
                self.showErrorAlert()
            }
        }

        self.timer.didFailCheck()
    }

    public func updater(_ updater: SUUpdater, failedToDownloadUpdate item: SUAppcastItem, error: Error) {
        self.logger.error("Sparkle failed to download update with error: \(String(describing: error))")
        self.timer.didFailCheck()
    }

    public func updaterWillShowModalAlert(_ updater: SUUpdater) {
        self.showErrorDialog = true
        self.logger.log("Sparkle will show modal alert")
    }

    public func updater(_ updater: SUUpdater, willDownloadUpdate item: SUAppcastItem, with request: NSMutableURLRequest) {
        self.logger.log("Sparkle will download update from \(request)")
    }

    public func updater(_ updater: SUUpdater, didDownloadUpdate item: SUAppcastItem) {
        self.logger.log("Sparkle did download update. Next check: \(self.timer.nextCheckDate.description)")
    }

    public func updaterDidShowModalAlert(_ updater: SUUpdater) {
    }

    //    public func updaterMayCheck(forUpdates updater: SUUpdater) -> Bool {
//        self.logger.log("Sparkle asked for permission to check");
//        return true
//    }

}

/*
 Public key (SUPublicEDKey value) for this key is:

 DP+imgyOegheuDKQfK7ur191ScNFBpkTLFoTBJHfF30=
 
 
 Public key (SUPublicEDKey value) for this key is:

 DP+imgyOegheuDKQfK7ur191ScNFBpkTLFoTBJHfF30=
 */
