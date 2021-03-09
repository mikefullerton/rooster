//
//  DownloadingUpdateWindow.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 3/4/21.
//

import Cocoa
import RoosterCore
import Sparkle

class SparkleProgressWindowController: WindowController {

    @IBOutlet var progressIndicator: NSProgressIndicator!
    @IBOutlet var button: NSButton!
    @IBOutlet var text: NSTextField!
    @IBOutlet var smallStatusText: NSTextField!

    public var checkingForUpdateCompletion: ((SPUUserInitiatedCheckStatus) -> Void)?

    public var downloadingCompletion: ((SPUDownloadUpdateStatus) -> Void)?

    private var canCancel = false
    private var cancelled = false
    
    override init() {
        super.init()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.logger.log("deinit")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.progressIndicator?.startAnimation(self)
        
        self.window?.title = "Installer"
        self.button?.target = self
        self.button?.action = #selector(buttonWasPressed(_:))
        
        self.resetDisplayStrings()
    }
    
    func resetDisplayStrings() {
        self.button.title = "Cancel"
        self.text.stringValue = ""
        self.smallStatusText.stringValue = ""
    }
    
    @objc func buttonWasPressed(_ sender: Any?) {
        self.checkingForUpdateCompletion?(.canceled)
        self.downloadingCompletion?(.canceled)
        self.downloadingCompletion = nil
        self.checkingForUpdateCompletion = nil
        
        if self.canCancel {
            self.cancelled = true
            self.window?.orderOut(self)
        }
        
        self.logger.log("Cancel button pressed")
    }
    
    public func showCheckingForUpdates() {
        _ = self.window
        
        self.canCancel = true
        self.cancelled = false
        
        self.text.stringValue = "Checking for Updates…"
        self.smallStatusText.stringValue = ""
        self.button.title = "Cancel"
        
        self.startIndeterminateProgress()
    }
    
    public func showUserInitiatedUpdateCheck(completion updateCheckStatusCompletion: @escaping (SPUUserInitiatedCheckStatus) -> Void) {
        
        if self.cancelled {
            self.cancelled = false
            self.canCancel = false
            
            DispatchQueue.main.async {
                self.logger.log("Notified sparkle of cancel")
                updateCheckStatusCompletion(.canceled)
            }
            
        } else {
            self.showCheckingForUpdates()
            self.checkingForUpdateCompletion = updateCheckStatusCompletion
        }
    }

    public func dismissUserInitiatedUpdateCheck() {
        self.checkingForUpdateCompletion?(.done)
        self.checkingForUpdateCompletion = nil
    }

    func startIndeterminateProgress() {
        self.progressIndicator.isIndeterminate = true
        self.progressIndicator.startAnimation(self)
        self.progressIndicator.usesThreadedAnimation = true
    }
    
    func startProgress(_ minValue: Double, _ maxValue: Double) {
        self.progressIndicator.isIndeterminate = false
        self.progressIndicator.maxValue = maxValue
        self.progressIndicator.minValue = minValue
        self.progressIndicator.doubleValue = minValue
        self.progressIndicator.usesThreadedAnimation = true
        self.progressIndicator.startAnimation(self)
    }
    
    public func showDownloadInitiated(completion downloadUpdateStatusCompletion: @escaping (SPUDownloadUpdateStatus) -> Void) {
        self.checkingForUpdateCompletion = nil
        
        self.text.stringValue = "Downloading Update…"
        self.button.title = "Cancel"
        self.startIndeterminateProgress()
        self.downloadingCompletion = downloadUpdateStatusCompletion
    }
 
    public func showDownloadDidReceiveExpectedContentLength(_ expectedContentLength: UInt64) {
        self.text.stringValue = "Downloading Update…"
        self.button.title = "Cancel"
        
        self.startProgress(0.0, Double(expectedContentLength))

        self.logger.log("showDownloadDidReceiveExpectedContentLength: \(expectedContentLength)")
    }
    
    public func showDownloadDidReceiveData(ofLength length: UInt64) {
        
        self.logger.log("showDownloadDidReceiveData: \(length)")
        self.progressIndicator.increment(by: Double(length))
    }
    
    public func showDownloadDidStartExtractingUpdate() {
        self.text.stringValue = "Decompressing Update"

        self.startProgress(0.0, 1.0)
        self.logger.log("showDownloadDidStartExtractingUpdate")
    }
    
    public func showExtractionReceivedProgress(_ progress: Double) {
        self.logger.log("showExtractionReceivedProgress: \(progress)")
        self.progressIndicator.doubleValue = progress
    }
    
    public func showReady(toInstallAndRelaunch installUpdateHandler: @escaping (SPUInstallUpdateStatus) -> Void) {
        self.logger.log("showReady")
        
        self.progressIndicator.stopAnimation(self)
        
        DispatchQueue.main.async {
            installUpdateHandler(.installAndRelaunchUpdateNow)
        }
    }
    
    public func showInstallingUpdate() {
        self.text.stringValue = "Installing Update"
        self.logger.log("showInstallingUpdate")

        self.startIndeterminateProgress()
    }
    
    public func showSendingTerminationSignal() {
        self.logger.log("showSendingTerminationSignal")
    }
    
    public func showUpdateInstallationDidFinish(acknowledgement: @escaping () -> Void) {
        self.logger.log("showUpdateInstallationDidFinish")

        DispatchQueue.main.async {
            acknowledgement()
        }
    }
}
