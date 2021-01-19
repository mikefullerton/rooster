//
//  FirstLaunchWindowController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//

import Cocoa

protocol FirstLaunchWindowControllerDelegate : AnyObject {
    func firstLaunchWindowControllerShouldDismiss(_ firstLaunchWindowController: FirstLaunchWindowController)
    func firstLaunchWindowControllerShowHelp(_ firstLaunchWindowController: FirstLaunchWindowController)
    func firstLaunchWindowControllerShowSettings(_ firstLaunchWindowController: FirstLaunchWindowController)
    func firstLaunchWindowControllerShowCalendars(_ firstLaunchWindowController: FirstLaunchWindowController)
}

class FirstLaunchWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
 
    weak var delegate: FirstLaunchWindowControllerDelegate?
    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
    @IBAction @objc func dismissSelf(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.firstLaunchWindowControllerShouldDismiss(self)
        }
    }

    @IBAction @objc func showMoreInfo(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.firstLaunchWindowControllerShowHelp(self)
        }
    }

    @IBAction @objc func showSettings(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.firstLaunchWindowControllerShowSettings(self)
        }
    }

    @IBAction @objc func showCalendars(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.firstLaunchWindowControllerShowCalendars(self)
        }
    }

}
