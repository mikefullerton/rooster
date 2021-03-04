//
//  SparkleInformationWindowController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 3/4/21.
//

import Cocoa
import RoosterCore
import Sparkle

class SparkleInformationWindowController: WindowController {
    
    @IBOutlet weak var releaseNotesSpinner: NSProgressIndicator?
    
    @IBOutlet weak var releaseNotesContainerView: NSView!
    @IBOutlet weak var releaseNotesBoxView: NSBox!
    @IBOutlet weak var versionTextField: NSTextField!
    @IBOutlet weak var questionTextField: NSTextField!
    @IBOutlet weak var automaticallyInstallUpdatesButton: NSButton!
    @IBOutlet weak var installButton: NSButton!
    @IBOutlet weak var skipButton: NSButton!
    @IBOutlet weak var laterButton: NSButton!

    @IBOutlet weak var releaseNotesTextField: NSTextField!
    
    override func windowDidLoad() {
        super .windowDidLoad()
        
        self.automaticallyInstallUpdatesButton.isHidden = true
        self.skipButton.isHidden = true
    }
    
    override init() {
        super.init()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var showUpdateFoundCallback:                ((SPUUpdateAlertChoice) -> Void)?
    var showDownloadedUpdateFoundCallback:      ((SPUUpdateAlertChoice) -> Void)?
    var showResumableUpdateFoundCallback:       ((SPUInstallUpdateStatus) -> Void)?
    var showInformationalUpdateFoundCallback:   ((SPUInformationalUpdateAlertChoice) -> Void)?
    
    var updateItem: SUAppcastItem?
    
    var alreadyDownloaded: Bool = false
    
    @IBAction func installUpdate(_ sender: Any?) {
        if let callback = self.showUpdateFoundCallback {
            callback(.installUpdateChoice)
        }
        
        if let callback = self.showDownloadedUpdateFoundCallback {
            callback(.installUpdateChoice)
        }
        
        if let callback = self.showResumableUpdateFoundCallback {
            callback(.installAndRelaunchUpdateNow)
        }
        
        if let callback = self.showInformationalUpdateFoundCallback {
            
            if let url = self.updateItem?.infoURL {
                NSWorkspace.shared.open(url)
            }

            callback(.dismissInformationalNoticeChoice)
        }
    }
    
    @IBAction func skipThisVersion(_ sender: Any?) {
        if let callback = self.showUpdateFoundCallback {
            callback(.skipThisVersionChoice)
        }

        if let callback = self.showDownloadedUpdateFoundCallback {
            callback(.skipThisVersionChoice)
        }

        if let callback = self.showResumableUpdateFoundCallback {
            callback(.dismissUpdateInstallation)
        }

        if let callback = self.showInformationalUpdateFoundCallback {
            callback(.skipThisInformationalVersionChoice)
        }

    }
    
    @IBAction func remindMeLater(_ sender: Any?) {
        if let callback = self.showUpdateFoundCallback {
            callback(.installLaterChoice)
        }

        if let callback = self.showDownloadedUpdateFoundCallback {
            callback(.installLaterChoice)
        }

        if let callback = self.showResumableUpdateFoundCallback {
            callback(.dismissUpdateInstallation)
        }

        if let callback = self.showInformationalUpdateFoundCallback {
            callback(.dismissInformationalNoticeChoice)
        }
    }
    
    func updateTitleText() {
        if let updateItem = self.updateItem {
            if updateItem.isCriticalUpdate {
                self.versionTextField.stringValue = "An important update to Rooster is ready to install"
            } else if self.alreadyDownloaded {
                self.versionTextField.stringValue = "A new version of Rooster is ready to install!"
            } else {
                self.versionTextField.stringValue = "A new version of Rooster is available!"
            }
        }
    }
    
    func updateDesciptionText() {
        if let updateItem = self.updateItem {

            let updateItemVersion = updateItem.displayVersionString ?? ""
            let hostVersion =  Bundle.shortVersionString ?? ""
            
//            if (!self.versionDisplayer && [updateItemVersion isEqualToString:hostVersion] ) {
//                updateItemVersion = [updateItemVersion stringByAppendingFormat:@" (%@)", [self.updateItem versionString]];
//                hostVersion = [hostVersion stringByAppendingFormat:@" (%@)", self.host.version];
//            } else {
//                [self.versionDisplayer formatVersion:&updateItemVersion andVersion:&hostVersion];
//            }

            // We display a different summary depending on if it's an "info-only" item, or a "critical update" item, or if we've already downloaded the update and just need to relaunch
            var finalString = ""

            if updateItem.isInformationOnlyUpdate {
                finalString = "Rooster \(updateItemVersion) is now available--you have \(hostVersion). Would you like to learn more about this update on the web?"
            } else if updateItem.isCriticalUpdate {
                if (!self.alreadyDownloaded) {
                    finalString = "Rooster \(updateItemVersion) is now available--you have \(hostVersion). This is an important update; would you like to download it now?"
                } else {
                    finalString = "Rooster \(updateItemVersion) has been downloaded and is ready to use! This is an important update; would you like to install it and relaunch Rooster now?"
                }
            } else {
                if (!self.alreadyDownloaded) {
                    finalString = "Rooster \(updateItemVersion) is now available--you have \(hostVersion). Would you like to download it now?"
                } else {
                    finalString = "Rooster \(updateItemVersion) has been downloaded and is ready to use! Would you like to install it and relaunch Rooster now?"
                }
            }
            
            self.questionTextField.stringValue = finalString
        }
    }
    
    func updateReleaseNotes() {
        if let updateItem = self.updateItem {
            self.releaseNotesTextField.stringValue = updateItem.itemDescription
        }
    }
    
    
    func updateTextFields() {
        self.updateTitleText()
        self.updateDesciptionText()
        self.updateReleaseNotes()
    }
    
    public func showUpdateFound(with appcastItem: SUAppcastItem,
                                userInitiated: Bool,
                                reply: @escaping (SPUUpdateAlertChoice) -> Void) {
        
        self.updateItem = appcastItem
        self.logger.log("showUpdateFound with appcastItem: \(appcastItem.description), user initiated: \(userInitiated)")
        self.installButton.title = "Download"
        self.updateTextFields()
        
        self.showUpdateFoundCallback = reply
    }


    public func showDownloadedUpdateFound(with appcastItem: SUAppcastItem,
                                          userInitiated: Bool,
                                          reply: @escaping (SPUUpdateAlertChoice) -> Void) {
        
        self.updateItem = appcastItem
        self.logger.log("showDownloadedUpdateFound with appcastItem: \(appcastItem.description), user initiated: \(userInitiated)")
        self.installButton.title = "Install"
        self.updateTextFields()
        self.showDownloadedUpdateFoundCallback = reply
    }


    public func showResumableUpdateFound(with appcastItem: SUAppcastItem,
                                         userInitiated: Bool,
                                         reply: @escaping (SPUInstallUpdateStatus) -> Void) {

        self.updateItem = appcastItem
        self.logger.log("showResumableUpdateFound with appcastItem: \(appcastItem.description), user initiated: \(userInitiated)")
        self.installButton.title = "Install"
        self.updateTextFields()
        self.showResumableUpdateFoundCallback = reply
    }
    
    public func showInformationalUpdateFound(with appcastItem: SUAppcastItem,
                                             userInitiated: Bool,
                                             reply: @escaping (SPUInformationalUpdateAlertChoice) -> Void) {
        
        self.updateItem = appcastItem
        self.logger.log("showInformationalUpdateFound with appcastItem: \(appcastItem.description), user initiated: \(userInitiated)")
        self.installButton.title = "Learn More…"
        self.updateTextFields()

        self.showInformationalUpdateFoundCallback = reply
    }
    
    public func showUpdateReleaseNotes(with downloadData: SPUDownloadData) {
        self.logger.log("showUpdateReleaseNotes")
    }
    
    public func showUpdateReleaseNotesFailedToDownloadWithError(_ error: Error) {
        self.logger.error("showUpdateReleaseNotesFailedToDownloadWithError: \(error.localizedDescription)")
    }
}
