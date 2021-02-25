//
//  MenuBarNoMoreMeetingsView.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/14/21.
//

import Foundation
import AppKit

class MenuBarNoMeetingsListViewCell : NoMeetingsListViewCell, MenuBarItem {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHighlightable = true
    }
    
    func menuItemWasSelected() {
        NSApp.activate(ignoringOtherApps: true)
        AppDelegate.instance.mainWindowController?.showWindow(self)
    }
}
