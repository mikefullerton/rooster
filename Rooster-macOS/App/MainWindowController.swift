//
//  MainWindowController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//

import Cocoa
import RoosterCore

public class MainWindowController: WindowController {
    let mainWindowViewController = MainWindowViewController()

    override public func windowDidLoad() {
        super.windowDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mainWindowDidUpdate(_:)),
                                               name: MainWindowViewController.DidChangeEvent,
                                               object: self.mainWindowViewController)

        self.autosaveKey = "MainWindow"
        self.contentViewController = self.mainWindowViewController
    }

    @IBAction private func showSettings(_ sender: Any) {
        AppControllers.shared.showPreferencesWindow()
    }

    @IBAction private func fileRadar(_ sender: Any) {
        AppControllers.shared.showRadarAlert()
    }

    @IBAction private func getInvolved(_ sender: Any) {
        AppControllers.shared.showCodeAlert()
    }

    @objc func mainWindowDidUpdate(_ notification: Notification) {
        if let window = self.window {
            let preferredContentSize = self.mainWindowViewController.preferredContentSize
            self.logger.debug("Updating main window size: \(String(describing: preferredContentSize))")
            window.setContentSize(preferredContentSize)
        }
    }

    func mainWindowViewController(_ viewController: MainWindowViewController,
                                  preferredContentSizeDidChange size: CGSize) {
    }
}
