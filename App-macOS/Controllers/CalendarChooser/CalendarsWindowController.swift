//
//  CalendarsWindowController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/21/21.
//

import Cocoa

class CalendarsWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        self.contentViewController = CalendarChooserViewController()
    }
}
