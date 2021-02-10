//
//  MainWindowController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//

import Cocoa

class MainWindowController: WindowController {
    
    let mainWindowViewController = MainWindowViewController()

    override func windowDidLoad() {
        super.windowDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mainWindowDidUpdate(_:)),
                                               name: MainWindowViewController.DidChangeEvent, object: self.mainWindowViewController)
    
        self.autosaveKey = "MainWindow"
        self.setContentViewController(self.mainWindowViewController)
        
//        self.mainWindowViewController.view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
    }
    
    @IBAction @objc func showSettings(_ sender: Any) {
        PreferencesWindow.show()
    }
    
    @IBAction @objc func fileRadar(_ sender: Any) {
        AppDelegate.instance.showRadarAlert()
    }

    @IBAction @objc func getInvolved(_ sender: Any) {
        AppDelegate.instance.showCodeAlert()
    }

    @objc func mainWindowDidUpdate(_ notification: Notification) {
        if let window = self.window {
            let preferredContentSize = self.mainWindowViewController.preferredContentSize
            self.logger.log("Updating main window size: \(NSStringFromSize(preferredContentSize))")
            window.setContentSize(preferredContentSize)
        }
    }

    func mainWindowViewController(_ viewController: MainWindowViewController, preferredContentSizeDidChange size: CGSize) {
    }

}
