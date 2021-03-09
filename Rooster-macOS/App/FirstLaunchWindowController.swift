//
//  FirstLaunchWindowController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//

import Cocoa
import RoosterCore


protocol FirstLaunchWindowControllerDelegate : AnyObject {
    func firstLaunchWindowControllerShouldDismiss(_ firstLaunchWindowController: FirstLaunchWindowController)
    func firstLaunchWindowControllerShowHelp(_ firstLaunchWindowController: FirstLaunchWindowController)
    func firstLaunchWindowControllerShowSettings(_ firstLaunchWindowController: FirstLaunchWindowController)
    func firstLaunchWindowControllerShowCalendars(_ firstLaunchWindowController: FirstLaunchWindowController)
}

class FirstLaunchWindowController: ModalWindowController {
 
    weak var delegate: FirstLaunchWindowControllerDelegate?
    
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
