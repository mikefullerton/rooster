//
//  MenuBarEventListListView.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/9/21.
//

import Foundation
import RoosterCore
import Cocoa

class MenuBarEventListListViewCell: EventListListViewCell, MenuBarItem {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateForMenuBar()
    }
}
