//
//  MenuBarReminderListListViewCell.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/9/21.
//

import Foundation
import Cocoa

class MenuBarReminderListViewCell: ReminderListViewCell, MenuBarItem {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateForMenuBar()
    }
}
