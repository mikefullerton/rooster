//
//  MainWindowController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//

import Cocoa

class MainWindowController: NSWindowController {

    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.contentViewController = MainViewViewController()
    }
    
    @IBAction @objc func showSettings(_ sender: Any) {
        let windowController = PreferencesWindowController(windowNibName: "PreferencesWindowController")
        NSApp.runModal(for: windowController.window!)
    }

    @IBAction @objc func showCalendars(_ sender: Any) {
        let windowController = CalendarsWindowController(windowNibName: "CalendarsWindowController")
        NSApp.runModal(for: windowController.window!)
    }

}
