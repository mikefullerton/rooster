//
//  MainWindowController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//

import Cocoa
import RoosterCore

public class TitleBarAccessoryViewController: NSTitlebarAccessoryViewController {
    override public func viewDidLayout() {
        super.viewDidLayout()

        self.fixSize()
    }

    override public func viewWillAppear() {
        super.viewWillAppear()

        self.fixSize()
    }

    func fixSize() {
        guard let window = self.window else { return }

        let view = self.view
        var frame = view.frame

        let frameInWindow = view.convert(frame, from: nil)

        let windowFrame = window.frame

        frame.size.width = (windowFrame.size.width + frameInWindow.origin.x) // origin is negative
        view.frame = frame
    }
}

public class MainWindowController: WindowController {
    let mainWindowViewController = MainWindowViewController()

    @IBOutlet private var titleBarAccessoryViewController: NSViewController!

    @IBAction private func showSettings(_ sender: Any) {
        PreferencesWindow.show()
    }

    @IBAction private func fileRadar(_ sender: Any) {
        AppDelegate.instance.showRadarAlert()
    }

    @IBAction private func getInvolved(_ sender: Any) {
        AppDelegate.instance.showCodeAlert()
    }

    @IBAction private func toggleSplitView(_ sender: Any) {
        self.mainWindowViewController.toggleSplitView()
    }

    @objc func mainWindowDidUpdate(_ notification: Notification) {
        if let window = self.window {
            let preferredContentSize = self.mainWindowViewController.calculatedContentSize
            self.logger.debug("Updating main window size: \(String(describing: preferredContentSize))")
            window.setContentSize(preferredContentSize)
        }
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mainWindowDidUpdate(_:)),
                                               name: MainWindowViewController.DidChangeEvent,
                                               object: self.mainWindowViewController)

        self.autosaveKey = "MainWindow"
        self.setContentViewController(self.mainWindowViewController)

        if let titleBarAccessoryViewController = self.titleBarAccessoryViewController as? TitleBarAccessoryViewController {
            titleBarAccessoryViewController.layoutAttribute = .left
            titleBarAccessoryViewController.automaticallyAdjustsSize = true
            self.window?.addTitlebarAccessoryViewController(titleBarAccessoryViewController)
        }
    }
}
