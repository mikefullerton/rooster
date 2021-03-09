//
//  MenuBarEventListListView.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/9/21.
//

import Cocoa
import Foundation
import RoosterCore

public class MenuBarEventListListViewCell: EventListListViewCell, MenuBarItem {
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.updateForMenuBar()
    }
}
