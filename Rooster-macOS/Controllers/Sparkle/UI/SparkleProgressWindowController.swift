//
//  DownloadingUpdateWindow.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 3/4/21.
//

import Cocoa
import RoosterCore
import Sparkle

public class SparkleProgressWindowController: WindowController {
    @IBOutlet private var progressIndicator: NSProgressIndicator!
    @IBOutlet private var button: NSButton!
    @IBOutlet private var text: NSTextField!
    @IBOutlet private var smallStatusText: NSTextField!

    private var checkingForUpdateCompletion: ((SPUUserInitiatedCheckStatus) -> Void)? {
        didSet {
            if self.checkingForUpdateCompletion != nil {
                self.downloadingCompletion = nil
                self.startInstallCompletion = nil
            }
        }
    }

    private var downloadingCompletion: ((SPUDownloadUpdateStatus) -> Void)? {
        didSet {
            if self.downloadingCompletion != nil {
                self.checkingForUpdateCompletion = nil
                self.startInstallCompletion = nil
            }
        }
    }

    private var startInstallCompletion: ((SPUInstallUpdateStatus) -> Void)? {
        didSet {
            if self.startInstallCompletion != nil {
                self.checkingForUpdateCompletion = nil
                self.downloadingCompletion = nil
            }
        }
    }

    private var canCancel = false
    private var cancelled = false

    override init() {
        super.init()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        self.logger.log("deinit")
    }

    override public func windowDidLoad() {
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

    private func clearCallbacks() {
        self.checkingForUpdateCompletion = nil
        self.downloadingCompletion = nil
        self.startInstallCompletion = nil
    }

    @objc func buttonWasPressed(_ sender: Any?) {
        // only one of these will be non-nil
        self.checkingForUpdateCompletion?(.canceled)
        self.downloadingCompletion?(.canceled)
        self.startInstallCompletion?(.installAndRelaunchUpdateNow)

        self.clearCallbacks()

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

        self.text.stringValue = "Checking for updates…"
        self.smallStatusText.stringValue = ""
        self.button.title = "Cancel"

        self.startIndeterminateProgress()
    }

    public func showUserInitiatedUpdateCheck(completion updateCheckStatusCompletion: @escaping (SPUUserInitiatedCheckStatus) -> Void) {
        if self.cancelled {
            self.cancelled = false
            self.canCancel = false
            self.clearCallbacks()

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
        self.text.stringValue = "Downloading update…"
        self.button.title = "Cancel"
        self.startIndeterminateProgress()
        self.downloadingCompletion = downloadUpdateStatusCompletion
    }

    public func showDownloadDidReceiveExpectedContentLength(_ expectedContentLength: UInt64) {
        self.text.stringValue = "Downloading update…"
        self.button.title = "Cancel"

        self.startProgress(0.0, Double(expectedContentLength))

        self.logger.log("showDownloadDidReceiveExpectedContentLength: \(expectedContentLength)")
    }

    public func showDownloadDidReceiveData(ofLength length: UInt64) {
        self.logger.log("showDownloadDidReceiveData: \(length)")
        self.progressIndicator.increment(by: Double(length))
    }

    public func showDownloadDidStartExtractingUpdate() {
        self.text.stringValue = "Decompressing update…"

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
        self.text.stringValue = "Update is ready to install"
        self.button.title = "Install"
        self.startInstallCompletion = installUpdateHandler
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
