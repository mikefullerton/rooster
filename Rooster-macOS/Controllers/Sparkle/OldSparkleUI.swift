//
//  SparkleUI.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/20/21.
//

import Foundation
import RoosterCore
import Sparkle

public class OldSparkleUI: NSObject, SPUStandardUserDriverDelegate, Loggable {
    private var userDriver: SPUUserDriver?
    private var showErrorDialog = false

    public func standardUserDriverWillShowModalAlert() {
        self.showErrorDialog = true
        self.logger.log("Sparkle will show modal alert")
    }

    public func standardUserDriverDidShowModalAlert() {
        self.logger.log("Sparkle did show modal alert")
    }

    func showErrorAlert() {
        if self.showErrorDialog {
            self.showErrorDialog = false
            self.logger.log("Showing custom error alert")

            let alert = NSAlert()
            alert.messageText = NSLocalizedString("UPDATING_FAILED", bundle: Bundle(for: type(of: self)), comment: "")
            alert.informativeText = NSLocalizedString("CONFIRM_INTERNAL_NETWORK", bundle: Bundle(for: type(of: self)), comment: "")
            alert.alertStyle = NSAlert.Style.informational
            alert.addButton(withTitle: NSLocalizedString("OK", bundle: Bundle(for: type(of: self)), comment: ""))
            _ = alert.runModal()
        }
    }

    func userDriver(for hostBundle: Bundle) -> SPUUserDriver {
        let driver = SPUStandardUserDriver(hostBundle: hostBundle, delegate: self)
        self.userDriver = driver

        return driver
    }
}
