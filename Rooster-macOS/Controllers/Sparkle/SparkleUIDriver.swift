//
//  SparkleUIDriver.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 3/3/21.
//

import Foundation
import Sparkle
import RoosterCore

class SparkleUIDriver: NSObject, SPUUserDriver, Loggable {
    
    func showCanCheck(forUpdates canCheckForUpdates: Bool) {
        self.logger.log("Can check for updates: \(canCheckForUpdates)")
    }
    
    func show(_ request: SPUUpdatePermissionRequest, reply: @escaping (SUUpdatePermissionResponse) -> Void) {
        self.logger.log("showing permission request: \(request.description)")

        DispatchQueue.main.async {
            reply(SUUpdatePermissionResponse(automaticUpdateChecks: false, sendSystemProfile: false))
        }
    }
    
    func showUserInitiatedUpdateCheck(completion updateCheckStatusCompletion: @escaping (SPUUserInitiatedCheckStatus) -> Void) {

        CheckingForUpdatesWindow.close()

        self.logger.log("showUserInitiatedUpdateCheck")

        DispatchQueue.main.async {
            updateCheckStatusCompletion(.done)
        }
    }
    
    func dismissUserInitiatedUpdateCheck() {

        CheckingForUpdatesWindow.close()

        self.logger.log("dismissUserInitiatedUpdateCheck")
        
    }
    
    func showUpdateFound(with appcastItem: SUAppcastItem, userInitiated: Bool, reply: @escaping (SPUUpdateAlertChoice) -> Void) {
        CheckingForUpdatesWindow.close()

        self.logger.log("showUpdateFound with appcastItem: \(appcastItem.description), user initiated: \(userInitiated)")

        DispatchQueue.main.async {
            reply(.installUpdateChoice)
        }
    }
    
    func showDownloadedUpdateFound(with appcastItem: SUAppcastItem, userInitiated: Bool, reply: @escaping (SPUUpdateAlertChoice) -> Void) {
        CheckingForUpdatesWindow.close()

        self.logger.log("showDownloadedUpdateFound with appcastItem: \(appcastItem.description), user initiated: \(userInitiated)")

        DispatchQueue.main.async {
            reply(.installUpdateChoice)
        }
    }
    
    func showResumableUpdateFound(with appcastItem: SUAppcastItem, userInitiated: Bool, reply: @escaping (SPUInstallUpdateStatus) -> Void) {
        CheckingForUpdatesWindow.close()

        self.logger.log("showResumableUpdateFound with appcastItem: \(appcastItem.description), user initiated: \(userInitiated)")
        
        DispatchQueue.main.async {
            reply(.installAndRelaunchUpdateNow)
        }
    }
    
    func showInformationalUpdateFound(with appcastItem: SUAppcastItem, userInitiated: Bool, reply: @escaping (SPUInformationalUpdateAlertChoice) -> Void) {
        CheckingForUpdatesWindow.close()

        self.logger.log("showInformationalUpdateFound with appcastItem: \(appcastItem.description), user initiated: \(userInitiated)")
        
        DispatchQueue.main.async {
            reply(.dismissInformationalNoticeChoice)
        }
    }
    
    func showUpdateReleaseNotes(with downloadData: SPUDownloadData) {
        CheckingForUpdatesWindow.close()
        self.logger.log("showUpdateReleaseNotes")
    }
    
    func showUpdateReleaseNotesFailedToDownloadWithError(_ error: Error) {
        CheckingForUpdatesWindow.close()
        self.logger.error("showUpdateReleaseNotesFailedToDownloadWithError: \(error.localizedDescription)")
    }
  
    func showUpdateNotFoundWithError(_ error: Error, acknowledgement: @escaping () -> Void) {
        
        CheckingForUpdatesWindow.close()
  
//        You’re up-to-date! NSError:Error Domain=SUSparkleErrorDomain Code=1001 "You’re up-to-date!" UserInfo={NSLocalizedRecoveryOptions=(
//        OK
//        ), NSLocalizedDescription=You’re up-to-date!, NSLocalizedRecoverySuggestion=Rooster 1.0.43 is currently the newest version available.}
//
        let alert: NSAlert = NSAlert()
        
        let nsError = error as NSError
            
        alert.messageText = "\(error.localizedDescription)"
        
        if let recoveryInfo = nsError.localizedRecoverySuggestion {
            alert.informativeText = recoveryInfo
        }
    
        if nsError.domain == "SUSparkleErrorDomain" && nsError.code == 1001 {
            alert.alertStyle = NSAlert.Style.informational
            self.logger.log("update check completed ok - no updated needed: \(nsError.localizedDescription): \(nsError.localizedRecoverySuggestion ?? "")")
        } else {
            alert.alertStyle = NSAlert.Style.critical
            self.logger.error("showUpdateNotFoundWithError: \(nsError.localizedDescription): \(nsError.localizedRecoverySuggestion ?? "")")
        }
    
        alert.addButton(withTitle: NSLocalizedString("OK", bundle: Bundle(for: type(of: self)), comment: ""))
        let _ = alert.runModal()
        
        DispatchQueue.main.async {
            acknowledgement()
        }
    }
    
    func showUpdaterError(_ error: Error, acknowledgement: @escaping () -> Void) {

        CheckingForUpdatesWindow.close()

        self.logger.error("showUpdaterError: \(error.localizedDescription)")
        DispatchQueue.main.async {
            acknowledgement()
        }
    }
    
    func showDownloadInitiated(completion downloadUpdateStatusCompletion: @escaping (SPUDownloadUpdateStatus) -> Void) {

        CheckingForUpdatesWindow.close()

        self.logger.log("showDownloadInitiated")

        DispatchQueue.main.async {
            downloadUpdateStatusCompletion(.done)
        }
    }
    
    func showDownloadDidReceiveExpectedContentLength(_ expectedContentLength: UInt64) {
        self.logger.log("showDownloadDidReceiveExpectedContentLength: \(expectedContentLength)")
    }
    
    func showDownloadDidReceiveData(ofLength length: UInt64) {
        self.logger.log("showDownloadDidReceiveData: \(length)")
    }
    
    func showDownloadDidStartExtractingUpdate() {
        self.logger.log("showDownloadDidStartExtractingUpdate")
    }
    
    func showExtractionReceivedProgress(_ progress: Double) {
        self.logger.log("showExtractionReceivedProgress: \(progress)")
    }
    
    func showReady(toInstallAndRelaunch installUpdateHandler: @escaping (SPUInstallUpdateStatus) -> Void) {
        self.logger.log("showReady")
        DispatchQueue.main.async {
            installUpdateHandler(.installAndRelaunchUpdateNow)
        }
    }
    
    func showInstallingUpdate() {
        self.logger.log("showInstallingUpdate")
    }
    
    func showSendingTerminationSignal() {
        self.logger.log("showSendingTerminationSignal")
    }
    
    func showUpdateInstallationDidFinish(acknowledgement: @escaping () -> Void) {
        self.logger.log("showUpdateInstallationDidFinish")

        DispatchQueue.main.async {
            acknowledgement()
        }
    }
    
    func dismissUpdateInstallation() {
        self.logger.log("dismissUpdateInstallation")
    }
}

extension SparkleUIDriver {
    public func showInternalNetworkErrorAlert() {
        self.logger.log("Showing custom error alert");
        
        let alert: NSAlert = NSAlert()
        alert.messageText = NSLocalizedString("UPDATING_FAILED", bundle: Bundle(for: type(of: self)), comment: "")
        alert.informativeText = NSLocalizedString("CONFIRM_INTERNAL_NETWORK", bundle: Bundle(for: type(of: self)), comment: "")
        alert.alertStyle = NSAlert.Style.informational
        alert.addButton(withTitle: NSLocalizedString("OK", bundle: Bundle(for: type(of: self)), comment: ""))
        let _ = alert.runModal()
    
    }
}
