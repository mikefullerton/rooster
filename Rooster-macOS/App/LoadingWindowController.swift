//
//  LoadingViewController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//

import Cocoa

class LoadingWindowController: WindowController {

    @IBOutlet var spinner: NSProgressIndicator?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.spinner?.startAnimation(self)
    }
    
}
