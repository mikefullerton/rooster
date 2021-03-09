//
//  LoadingViewController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//

import Cocoa
import RoosterCore

public class LoadingWindowController: WindowController {
    @IBOutlet private var spinner: NSProgressIndicator?

    override public func windowDidLoad() {
        super.windowDidLoad()
        self.spinner?.startAnimation(self)
    }
}
