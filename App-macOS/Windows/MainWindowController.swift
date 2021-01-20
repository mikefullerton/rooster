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
        
    }

    @IBAction @objc func showCalendars(_ sender: Any) {
        
    }



    
}
