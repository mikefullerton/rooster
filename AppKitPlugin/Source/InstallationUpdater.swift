//
//  SparkleSupport.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/19/20.
//

import Foundation
import Sparkle

@objc public class InstallationUpdater : NSObject, AppKitInstallationUpdater, SUUpdaterDelegate {
    
    public weak var delegate: AppKitInstallationUpdaterDelegate?
    
    private var updater: SUUpdater? = nil
    private var error: Error?
    
    public override init() {
        
    }
    
    public func configure(withAppBundle appBundle: Bundle) {
        if let updater = SUUpdater.init(for: appBundle) {
            updater.delegate = self
            updater.sendsSystemProfile = false
            updater.automaticallyChecksForUpdates = true
            updater.automaticallyDownloadsUpdates = true
            self.updater = updater
            print("Sparkle updater configured. Last update check was: \(String(describing: updater.lastUpdateCheckDate))")
        }
    }
    
    public func checkForUpdates() {
        self.updater?.checkForUpdates(self)
    }
    
    public func updaterDidNotFindUpdate(_ updater: SUUpdater) {
        print("Sparkle did not find update")
    }
    
//    public func updaterShouldPromptForPermissionToCheck(forUpdates updater: SUUpdater) -> Bool {
//        print("Sparkle asked for permission to check")
//        return true
//    }
    
    public func showErrorAlert() {
        let alert: NSAlert = NSAlert()
        alert.messageText = "Updating Rooster failed!"
        alert.informativeText = "Make sure you're on the Apple Internal network"
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "OK")
        let _ = alert.runModal()
    }
    
    public func updater(_ updater: SUUpdater, didAbortWithError error: Error) {
        print("Sparkle did abort with error: \(error)")
        if let nsError = error as NSError? {
            if nsError.domain == SUSparkleErrorDomain && nsError.code == SUError.appcastError.rawValue {
                self.showErrorAlert()
            }
        }
    }
    
    public func updater(_ updater: SUUpdater, failedToDownloadUpdate item: SUAppcastItem, error: Error) {
        print("Sparkle failed to download update with error: \(error)")
    }
    
    public func updater(_ updater: SUUpdater, didFindValidUpdate item: SUAppcastItem) {
        print("Sparkle did find valid update");
    }
    
    public func updaterWillShowModalAlert(_ updater: SUUpdater) {
        print("Sparkle will show modal alert");
    }
    
    public func updater(_ updater: SUUpdater, willDownloadUpdate item: SUAppcastItem, with request: NSMutableURLRequest) {
        print("Sparkle will download update from \(request)")
    }

    public func updater(_ updater: SUUpdater, didDownloadUpdate item: SUAppcastItem) {
        print("Sparkle did download update")
    }

    public func updaterDidShowModalAlert(_ updater: SUUpdater) {
        
    }
    
//    public func updaterMayCheck(forUpdates updater: SUUpdater) -> Bool {
//        print("Sparkle asked for permission to check");
//        return true
//    }
    
    
}

/*
 Public key (SUPublicEDKey value) for this key is:

 DP+imgyOegheuDKQfK7ur191ScNFBpkTLFoTBJHfF30=
 
 
 Public key (SUPublicEDKey value) for this key is:

 DP+imgyOegheuDKQfK7ur191ScNFBpkTLFoTBJHfF30=
 */
