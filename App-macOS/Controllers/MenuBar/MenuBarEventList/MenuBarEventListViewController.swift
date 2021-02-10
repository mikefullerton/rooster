//
//  EventListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class MenuBarEventListViewController : CalendarItemTableViewController<MenuBarEventListViewModel> {
    
    override func provideDataModel() -> MenuBarEventListViewModel? {
        return MenuBarEventListViewModel(withEvents: AppDelegate.instance.dataModelController.dataModel.events,
                                         reminders: AppDelegate.instance.dataModelController.dataModel.reminders)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.sdkLayer.backgroundColor = NSColor.clear.cgColor
        self.collectionView.backgroundColors = [ .clear ]
        self.scrollView.drawsBackground = false
        self.scrollView.contentView.drawsBackground = false
        
        self.collectionView.trackingAreaEnabled = true
    }
}
