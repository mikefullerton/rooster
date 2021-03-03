//
//  SparkleSupport.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/19/20.
//

import Foundation
import RoosterCore
import Sparkle

#if targetEnvironment(macCatalyst)

#else
protocol AppKitInstallationUpdater {}
#endif

public class SparkleController : NSObject, Loggable, SparkleTimerDelegate {
    
    private var updater: SPUUpdater? = nil
    private var error: Error?
    private lazy var timer = SparkleTimer(withDelegate: self)
    lazy var sparkleUIDriver = SparkleUIDriver()

    func checkForUpdatesIfNeeded() {
        self.timer.stop()
        self.logger.log("Starting to check if check for new update is needed")
        
        DispatchQueue.main.async {
            if let updater = self.updater {
                if self.timer.isTimeForUpdate {
                    self.logger.log("Starting check for updates in the backgound on feed: \(updater.feedURL)")
                    updater.checkForUpdatesInBackground()
                } else {
                    self.logger.log("Not checking for updates yet")
                    self.timer.startNextCheckTimer()
                }
            }
        }
    }
    
    @objc func appDidBecomeActiveNotification(_ sender: Notification) {
        self.checkForUpdatesIfNeeded()
    }
    
    func sparkleTimerCheckForUpdates(_ timer: SparkleTimer) {
        self.checkForUpdatesIfNeeded()
    }

    public func configure(withAppBundle appBundle: Bundle) {
        
        let updater = SPUUpdater(hostBundle: appBundle,
                                 applicationBundle: appBundle,
                                 userDriver: self.sparkleUIDriver,
                                 delegate: self)

        updater.sendsSystemProfile = false
        updater.automaticallyChecksForUpdates = false // this updates its check date if it fails. Dumb.
        updater.automaticallyDownloadsUpdates = true
        
        do {
            try updater.start()
        } catch let error {
            self.logger.error("Failed to start with error: \(error.localizedDescription)")

            // TODO: put up alert.
            
            return
        }
        
        self.updater = updater
        
        self.logger.log("Updater configured. Last update check was: \(self.timer.lastUpdateCheckDate?.description ?? "None" )")
        
        self.checkForUpdatesIfNeeded()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomeActiveNotification(_:)),
                                               name: NSApplication.didBecomeActiveNotification, object: nil)
    }
    
    public func checkForUpdates() {
        self.logger.log("User requested update check");
        CheckingForUpdatesWindow.show()

        self.timer.stop()
        if let updater = self.updater {
            updater.checkForUpdates()
        }
    }
}

extension SparkleController : SPUUpdaterDelegate {

    
    public func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        self.logger.log("Found valid update for item: \(item.description) - (will automatically download)");
        self.timer.didSuccessfullyCheck()
    }
    
    public func updaterDidNotFindUpdate(_ updater: SPUUpdater) {
        self.logger.log("No updates found")
        self.timer.didSuccessfullyCheck()
    }
    
//    public func updaterShouldPromptForPermissionToCheck(forUpdates updater: SUUpdater) -> Bool {
//        self.logger.log("Sparkle asked for permission to check")
//        return true
//    }
    
    public func updater(_ updater: SPUUpdater, didAbortWithError error: Error) {
        self.logger.error("Updater did abort with error: \(error.localizedDescription)")
        if let nsError = error as NSError? {
            if nsError.domain == SUSparkleErrorDomain && nsError.code == SUError.appcastError.rawValue {
                self.sparkleUIDriver.showInternalNetworkErrorAlert()
            }
        }
        
        self.timer.didFailCheck()
    }
    
    public func updater(_ updater: SPUUpdater, failedToDownloadUpdate item: SUAppcastItem, error: Error) {
        self.logger.error("failed to download item: \(item.description), update with error: \(error.localizedDescription)")
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
        return true
    }
    //    public func updaterMayCheck(forUpdates updater: SUUpdater) -> Bool {
//        self.logger.log("Sparkle asked for permission to check");
//        return true
//    }

}

extension SUAppcastItem {
    
    
    
}
