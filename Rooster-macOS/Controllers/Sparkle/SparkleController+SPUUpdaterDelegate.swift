//
//  SparkleControler+SPUDelegate.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 3/4/21.
//

import Foundation
import RoosterCore
import Sparkle

extension SparkleController: SPUUpdaterDelegate {
    public func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        self.logger.log("Found valid update for item: \(item.description) - (will automatically download)")
        self.timer.didSuccessfullyCheck()
    }

    public func updaterDidNotFindUpdate(_ updater: SPUUpdater) {
        self.logger.log("No updates found")
        self.timer.didSuccessfullyCheck()
    }

    //    public func updaterMayCheck(forUpdates updater: SUUpdater) -> Bool {
//        self.logger.log("Sparkle asked for permission to check");
//        return true
//    }

//    public func updaterShouldPromptForPermissionToCheck(forUpdates updater: SUUpdater) -> Bool {
//        self.logger.log("Sparkle asked for permission to check")
//        return true
//    }

    public func updater(_ updater: SPUUpdater, didAbortWithError error: Error) {
        self.logger.error("Updater did abort with error: \(String(describing: error))")

        self.timer.didFailCheck()
    }

    public func updater(_ updater: SPUUpdater, failedToDownloadUpdate item: SUAppcastItem, error: Error) {
        self.logger.error("failed to download item: \(item.description), update with error: \(String(describing: error))")
        self.timer.didFailCheck()
    }

    public func updater(_ updater: SPUUpdater, willDownloadUpdate item: SUAppcastItem, with request: NSMutableURLRequest) {
        self.logger.log("will download update for item: \(item.description), from: \(request)")
    }

    public func updater(_ updater: SPUUpdater, didDownloadUpdate item: SUAppcastItem) {
        self.logger.log("did download update for item: \(item.description).")
    }

    public func updater(_ updater: SPUUpdater, willInstallUpdate item: SUAppcastItem) {
        self.logger.log("will install update for item: \(item.description).")
    }

    public func updater(_ updater: SPUUpdater, didFinishLoading appcast: SUAppcast) {
        self.logger.log("did finish loading appcast: \(appcast.description)")
    }

    public func updater(_ updater: SPUUpdater, shouldAllowInstallerInteractionFor updateCheck: SPUUpdateCheck) -> Bool {
        true
    }

    public func showCanCheck(forUpdates canCheckForUpdates: Bool) {
        self.logger.log("Can check for updates: \(canCheckForUpdates)")
    }
}
