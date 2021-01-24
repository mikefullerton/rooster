//
//  MainWindowController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//

import Cocoa

class MainWindowController: WindowController, MainWindowViewControllerDelegate {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        let viewController = MainWindowViewController()
        viewController.delegate = self
        self.autosaveKey = "MainWindow"
        self.setContentViewController(viewController)
        
        viewController.view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
    }
    
    @IBAction @objc func showSettings(_ sender: Any) {
        PreferencesWindow().showWindow(self)
    }
    
    func mainWindowViewController(_ viewController: MainWindowViewController, preferredContentSizeDidChange size: CGSize) {
        if let window = self.window {
            window.setContentSize(size)
        }
    }

}
