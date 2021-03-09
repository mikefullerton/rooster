//
//  SparkleUIDriver.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 3/3/21.
//

import Foundation
import Sparkle
import RoosterCore

extension SparkleController: SPUUserDriver {
    
    public func show(_ request: SPUUpdatePermissionRequest, reply: @escaping (SUUpdatePermissionResponse) -> Void) {
        self.logger.log("showing permission request: \(request.description)")

        self.state += .updatePermissions
        
        DispatchQueue.main.async {
            self.state -= .updatePermissions
            reply(SUUpdatePermissionResponse(automaticUpdateChecks: false, sendSystemProfile: false))
        }
    }
    
    public func showUserInitiatedUpdateCheck(completion updateCheckStatusCompletion: @escaping (SPUUserInitiatedCheckStatus) -> Void) {
        self.logger.log("showUserInitiatedUpdateCheck")
        self.state += [ .checking, .userInitiated ]
        self.showProgressWindow().showUserInitiatedUpdateCheck(completion: updateCheckStatusCompletion)
    }
    
    public func dismissUserInitiatedUpdateCheck() {
        self.logger.log("dismissUserInitiatedUpdateCheck")
        self.showProgressWindow().dismissUserInitiatedUpdateCheck()
        self.hideProgressWindow()
        self.state = []
    }
    
    public func showUpdateFound(with appcastItem: SUAppcastItem, userInitiated: Bool, reply: @escaping (SPUUpdateAlertChoice) -> Void) {
        self.logger.log("showUpdateFound with appcastItem: \(appcastItem.description), user initiated: \(userInitiated)")
        self.state -= [ .checking, .userInitiated ]
        self.state += .foundNewVersion
        self.hideProgressWindow()
        self.showInfoWindow().showUpdateFound(with: appcastItem, userInitiated: userInitiated, reply: reply)
    }
    
    public func showDownloadedUpdateFound(with appcastItem: SUAppcastItem, userInitiated: Bool, reply: @escaping (SPUUpdateAlertChoice) -> Void) {
        self.logger.log("showDownloadedUpdateFound with appcastItem: \(appcastItem.description), user initiated: \(userInitiated)")
        self.state = .updateDownloaded
        self.hideProgressWindow()
        self.showInfoWindow().showDownloadedUpdateFound(with: appcastItem, userInitiated: userInitiated, reply: reply)
    }
    
    public func showResumableUpdateFound(with appcastItem: SUAppcastItem,
                                         userInitiated: Bool,
                                         reply: @escaping (SPUInstallUpdateStatus) -> Void) {
        self.logger.log("showResumableUpdateFound with appcastItem: \(appcastItem.description), user initiated: \(userInitiated)")
        self.state = .resumeableUpdateFound
        self.hideProgressWindow()
        self.showInfoWindow().showResumableUpdateFound(with: appcastItem, userInitiated: userInitiated, reply: reply)
    }
    
    public func showInformationalUpdateFound(with appcastItem: SUAppcastItem,
                                             userInitiated: Bool,
                                             reply: @escaping (SPUInformationalUpdateAlertChoice) -> Void) {
        self.state = .resumeableUpdateFound
        self.logger.log("showInformationalUpdateFound with appcastItem: \(appcastItem.description), user initiated: \(userInitiated)")
        self.hideProgressWindow()
        self.showInfoWindow().showInformationalUpdateFound(with: appcastItem, userInitiated: userInitiated, reply: reply)
    }
    
    public func showUpdateReleaseNotes(with downloadData: SPUDownloadData) {
        self.logger.log("showUpdateReleaseNotes")
        self.hideProgressWindow()
        self.showInfoWindow().showUpdateReleaseNotes(with: downloadData)
    }
    
    public func showUpdateReleaseNotesFailedToDownloadWithError(_ error: Error) {
        self.logger.error("showUpdateReleaseNotesFailedToDownloadWithError: \(error.localizedDescription)")
        self.hideProgressWindow()
        self.showInfoWindow().showUpdateReleaseNotesFailedToDownloadWithError(error)
    }
  
    public func showErrorAlert(_ error: Error) {
        let alert: NSAlert = NSAlert()
        
        let nsError = error as NSError
            
        alert.messageText = "\(error.localizedDescription)"
        
        if let recoveryInfo = nsError.localizedRecoverySuggestion {
            alert.informativeText = recoveryInfo
        }
    
        if nsError.domain == SUSparkleErrorDomain {
            
            if nsError.code == SUError.noUpdateError.rawValue {
                alert.alertStyle = NSAlert.Style.informational
        
                self.logger.log("update check completed ok - no updated needed: \(nsError.localizedDescription): \(nsError.localizedRecoverySuggestion ?? "")")
            } else if self.state.contains( [.checking,.userInitiated]) && nsError.code ==  SUError.appcastError.rawValue {
                self.logger.error("update check failed, user is not on internal network: \(nsError.localizedDescription): \(nsError.localizedRecoverySuggestion ?? "")")

                alert.messageText = NSLocalizedString("UPDATING_FAILED", bundle: Bundle(for: type(of: self)), comment: "")
                alert.informativeText = NSLocalizedString("CONFIRM_INTERNAL_NETWORK", bundle: Bundle(for: type(of: self)), comment: "")
                alert.alertStyle = NSAlert.Style.warning
                
            } else {
                alert.alertStyle = NSAlert.Style.critical
                self.logger.error("Sparkle Error: \(nsError.localizedDescription): \(nsError.localizedRecoverySuggestion ?? "")")
            }
        
        } else {

            alert.alertStyle = NSAlert.Style.critical
            self.logger.error("showUpdateNotFoundWithError: \(nsError.localizedDescription): \(nsError.localizedRecoverySuggestion ?? "")")
        }
    
        alert.addButton(withTitle: NSLocalizedString("OK", bundle: Bundle(for: type(of: self)), comment: ""))
        _ = alert.runModal()
        
    }
    
    public func showUpdateNotFoundWithError(_ error: Error, acknowledgement: @escaping () -> Void) {
        self.state += [ .failed ]
        self.showErrorAlert(error)
        
        self.hideProgressWindow()
//        self.hideInfoWindow()
        
        DispatchQueue.main.async {
            self.state = []
            acknowledgement()
        }
    }
    
    public func showUpdaterError(_ error: Error, acknowledgement: @escaping () -> Void) {
        self.logger.error("showUpdaterError: \(error.localizedDescription)")
        self.state += [ .failed ]
        self.showErrorAlert(error)
        
        DispatchQueue.main.async {
            self.state = []
            self.hideProgressWindow()
            acknowledgement()
        }
    }
    
    public func showDownloadInitiated(completion downloadUpdateStatusCompletion: @escaping (SPUDownloadUpdateStatus) -> Void) {
        
        self.hideInfoWindow()
        
        self.logger.log("showDownloadInitiated")
        self.state = .downloadInititiated
        self.showProgressWindow().showDownloadInitiated(completion: downloadUpdateStatusCompletion)
    }
    
    public func showDownloadDidReceiveExpectedContentLength(_ expectedContentLength: UInt64) {
        self.logger.log("showDownloadDidReceiveExpectedContentLength: \(expectedContentLength)")
        self.state = .downloading
        self.showProgressWindow().showDownloadDidReceiveExpectedContentLength(expectedContentLength)
    }
    
    public func showDownloadDidReceiveData(ofLength length: UInt64) {
        self.logger.log("showDownloadDidReceiveData: \(length)")
        self.showProgressWindow().showDownloadDidReceiveData(ofLength: length)
    }
    
    public func showDownloadDidStartExtractingUpdate() {
        self.hideInfoWindow()
        self.logger.log("showDownloadDidStartExtractingUpdate")
        self.state = .extracting
        self.showProgressWindow().showDownloadDidStartExtractingUpdate()
    }
    
    public func showExtractionReceivedProgress(_ progress: Double) {
        self.logger.log("showExtractionReceivedProgress: \(progress)")
        self.showProgressWindow().showExtractionReceivedProgress(progress)
    }
    
    public func showReady(toInstallAndRelaunch installUpdateHandler: @escaping (SPUInstallUpdateStatus) -> Void) {
        self.hideInfoWindow()
        self.logger.log("showReady")
        self.state = .readyToInstall
        self.showProgressWindow().showReady(toInstallAndRelaunch: installUpdateHandler)
    }
    
    public func showInstallingUpdate() {
        self.hideInfoWindow()
        self.logger.log("showInstallingUpdate")
        self.state = .installing
        self.showProgressWindow().showInstallingUpdate()
    }
    
    public func showSendingTerminationSignal() {
        self.logger.log("showSendingTerminationSignal")
        self.state = .terminating
        self.showProgressWindow().showSendingTerminationSignal()
    }
    
    public func showUpdateInstallationDidFinish(acknowledgement: @escaping () -> Void) {
        self.logger.log("showUpdateInstallationDidFinish")
        self.state = .finished
        self.hideInfoWindow()
        self.showProgressWindow().showUpdateInstallationDidFinish(acknowledgement: acknowledgement)
    }
    
    public func dismissUpdateInstallation() {
        self.logger.log("dismissUpdateInstallation")
        self.hideProgressWindow()
        self.hideInfoWindow()
        self.state = []
    }
}
