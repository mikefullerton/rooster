//
//  SparkleSupport.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/19/20.
//

import Foundation
//import Sparkle

#if targetEnvironment(macCatalyst)

#else
protocol AppKitInstallationUpdater {}
#endif

@objc public class SparkleController : NSObject, AppKitInstallationUpdater, SPUUpdaterDelegate, Loggable {
    
//    public weak var delegate: AppKitInstallationUpdaterDelegate?
    
    private var updater: SPUUpdater? = nil
    private var error: Error?
    private var timer: SimpleTimer
    
    public override init() {
        self.timer = SimpleTimer(withName: "SparkleUpdateTimer")
    }
    
    let nextUpdateCheckDateKey = "nextUpdateCheckDateKey"
    let lastUpdateCheckDateKey = "lastUpdateCheckDateKey"
    let tryAgainInterval:TimeInterval = 60 * 60
    let updateCheckInterval: TimeInterval = 60 * 60 * 24
    
    var nextCheckDate: Date {
        get {
            if let date = UserDefaults.standard.object(forKey: self.nextUpdateCheckDateKey) as? Date {
                return date
            }
            
            return Date()
        }
        set(newDate) {
            UserDefaults.standard.setValue(newDate, forKey: self.nextUpdateCheckDateKey)
        }
    }
    
    var lastUpdateCheckDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: self.lastUpdateCheckDateKey) as? Date
        }
        set(newDate) {
            if newDate == nil {
                UserDefaults.standard.removeObject(forKey: self.lastUpdateCheckDateKey)
            } else {
                UserDefaults.standard.setValue(newDate, forKey: self.lastUpdateCheckDateKey)
            }
        }
    }
   
    func removeNextCheckDate() {
        UserDefaults.standard.removeObject(forKey: self.nextUpdateCheckDateKey)
    }

    var isTimeForUpdate: Bool {
        return self.nextCheckDate.isEqualToOrBeforeDate(Date())
    }
    

    func startNextCheckTimer() {
        self.logger.log("Starting next check timer at \(Date()), will check again at \(self.nextCheckDate)")
        self.timer.start(withDate: self.nextCheckDate) { [weak self] timer in
            self?.logger.log("Timer expired, will check for updates if needed")
            self?.checkForUpdatesIfNeeded()
        }
    }
    
    func didSuccessfullyCheck() {
        self.lastUpdateCheckDate = Date()
        self.nextCheckDate = Date().addingTimeInterval(self.updateCheckInterval)
        self.logger.log("Did succussfully check for updates.")
        self.startNextCheckTimer()
    }
    
    func didFailCheck() {
        self.nextCheckDate = Date().addingTimeInterval(self.tryAgainInterval)
        self.logger.log("Did fail check for updates, will try again in \( Int(self.tryAgainInterval / 60)) minutes")
        self.startNextCheckTimer()
    }

    func checkForUpdatesIfNeeded() {
        self.timer.stop()
        self.logger.log("Starting to check if check for new update is needed")
        DispatchQueue.main.async {
            if let updater = self.updater {
//                if !updater.updateInProgress {
                    if self.isTimeForUpdate {
                        self.logger.log("Starting check for updates in the backgound on feed: \(updater.feedURL)")
                        updater.checkForUpdatesInBackground()
                    } else {
                        self.logger.log("Not checking for updates yet")
                        self.startNextCheckTimer()
                    }
//                } else {
//                    self.logger.log("Update in progress, not checking")
//                    self.startNextCheckTimer()
//                }
            }
        }
    }
    
    @objc func appDidBecomeActiveNotification(_ sender: Notification) {
        self.checkForUpdatesIfNeeded()
    }
    
    lazy var sparkleUI = SparkleUI()
    
    public func configure(withAppBundle appBundle: Bundle) {
        
        let updater = SPUUpdater(hostBundle: appBundle,
                                 applicationBundle: appBundle,
                                 userDriver: self.sparkleUI.userDriver(for: appBundle),
                                 delegate: self)

        updater.sendsSystemProfile = false
        updater.automaticallyChecksForUpdates = false // this updates its check date if it fails. Dumb.
        updater.automaticallyDownloadsUpdates = true
        
        do {
            try updater.start()
        } catch let error {
            self.logger.error("Sparkle failed to start with error: \(error.localizedDescription)")

            // TODO: put up alert.
            
            return
        }
        
        self.updater = updater
        
        self.logger.log("Sparkle updater configured. Last update check was: \(self.lastUpdateCheckDate?.description ?? "None" )")
        
        self.checkForUpdatesIfNeeded()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActiveNotification(_:)), name: NSApplication.didBecomeActiveNotification, object: nil)
    }
    
    public func checkForUpdates() {
        self.logger.log("User requested update check");
        self.timer.stop()
        if let updater = self.updater {
            updater.checkForUpdates()
        }
    }
    
    public func updaterDidNotFindUpdate(_ updater: SPUUpdater) {
        self.logger.log("Sparkle did not find update")
        self.didSuccessfullyCheck()
    }
    
    public func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        self.logger.log("Sparkle did find valid update (will automatically download)");
        self.didSuccessfullyCheck()
    }
    
//    public func updaterShouldPromptForPermissionToCheck(forUpdates updater: SUUpdater) -> Bool {
//        self.logger.log("Sparkle asked for permission to check")
//        return true
//    }
    
    public func updater(_ updater: SPUUpdater, didAbortWithError error: Error) {
        self.logger.error("Sparkle did abort with error: \(error.localizedDescription)")
        if let nsError = error as NSError? {
            if nsError.domain == SUSparkleErrorDomain && nsError.code == SUError.appcastError.rawValue {
                self.sparkleUI.showErrorAlert()
            }
        }
        
        self.didFailCheck()
    }
    
    public func updater(_ updater: SPUUpdater, failedToDownloadUpdate item: SUAppcastItem, error: Error) {
        self.logger.error("Sparkle failed to download update with error: \(error.localizedDescription)")
        self.didFailCheck()
    }

    
    public func updater(_ updater: SPUUpdater, willDownloadUpdate item: SUAppcastItem, with request: NSMutableURLRequest) {
        self.logger.log("Sparkle will download update from \(request)")
    }

    public func updater(_ updater: SPUUpdater, didDownloadUpdate item: SUAppcastItem) {
        self.logger.log("Sparkle did download update. Next check: \(self.nextCheckDate.description)")
    }

    //    public func updaterMayCheck(forUpdates updater: SUUpdater) -> Bool {
//        self.logger.log("Sparkle asked for permission to check");
//        return true
//    }
    
    
}

class SparkleUI : NSObject, SPUStandardUserDriverDelegate, Loggable {
    
    private var userDriver: SPUUserDriver? = nil
    private var showErrorDialog = false
    
    override init() {
    }
    
    func standardUserDriverWillShowModalAlert() {
        self.showErrorDialog = true
        self.logger.log("Sparkle will show modal alert");
    }
    
    func standardUserDriverDidShowModalAlert() {
        
    }

    public func showErrorAlert() {
        if self.showErrorDialog {
            self.showErrorDialog = false
        
            let alert: NSAlert = NSAlert()
            alert.messageText = NSLocalizedString("UPDATING_FAILED", bundle: Bundle(for: type(of: self)), comment: "")
            alert.informativeText = NSLocalizedString("CONFIRM_INTERNAL_NETWORK", bundle: Bundle(for: type(of: self)), comment: "")
            alert.alertStyle = NSAlert.Style.informational
            alert.addButton(withTitle: NSLocalizedString("OK", bundle: Bundle(for: type(of: self)), comment: ""))
            let _ = alert.runModal()
        }
    }
    
    func userDriver(for hostBundle: Bundle) -> SPUUserDriver {
        let driver = SPUStandardUserDriver(hostBundle: hostBundle, delegate: self)
        self.userDriver = driver
        
        return driver
        
    }
    
    
}
