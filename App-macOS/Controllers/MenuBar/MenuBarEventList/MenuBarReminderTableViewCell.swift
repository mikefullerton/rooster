//
//  MenuBarReminderListTableViewCell.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/9/21.
//

import Foundation
import Cocoa

class MenuBarReminderTableViewCell: ReminderTableViewCell {
    override func loadView() {
        super.loadView()
        self.updateForMenuBar()
    }
}
