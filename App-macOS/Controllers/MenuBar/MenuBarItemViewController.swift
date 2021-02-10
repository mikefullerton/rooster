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

class MenuBarItemViewController : CalendarItemListViewController<MenuBarItemViewModel>, MenuBarScrollViewDelegate, Loggable, AppControllerAware, NSMenuDelegate {
    
    override func provideDataModel() -> MenuBarItemViewModel? {
        return MenuBarItemViewModel(withEvents: AppDelegate.instance.dataModelController.dataModel.events,
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

    override var preferredContentSize: NSSize {
        get { return super.preferredContentSize }
        set(size) {
            super.preferredContentSize = size
            var frame = self.view.frame
            frame.size = self.preferredContentSize
            self.view.frame = frame
        }
    }
    
    func menuBarScrollViewWillAppear(_ scrollView: MenuBarScrollView) {
        self.viewWillAppear()
        
        self.becomeFirstResponder()
    }
    
    func menuBarScrollViewWillDisappear(_ scrollView: MenuBarScrollView) {
        self.viewWillDisappear()
    }
    
    func menuBarScrollViewDidAppear(_ scrollView: MenuBarScrollView) {
        self.viewDidAppear()
    }
    
    func menuBarScrollViewDidDisappear(_ scrollView: MenuBarScrollView) {
        self.viewDidDisappear()
    }

    override func createScrollView() -> NSScrollView {
        let scrollView = MenuBarScrollView()
        scrollView.menuBarDelegate = self
        return scrollView
    }

    func blink(item: SDKCollectionViewItem, count: Int) {
        
        let delay = 75
        
        if count == 0 {
            if let menu = self.scrollView.enclosingMenuItem?.menu {
                menu.cancelTrackingWithoutAnimation()
            }
            
            if let menuItem = item as? MenuBarItem {
                menuItem.menuItemWasSelected()
            } else {
                self.logger.error("tracking: failed to cast \(item) to menuItem")
            }
        } else {
            item.highlightState = item.highlightState == .forSelection ? .none : .forSelection
            item.view.needsDisplay = true
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(delay)) {
                self.blink(item: item, count: count - 1)
            }
        }
    }
    
    func handleMenuChoice(forItem item: NSCollectionViewItem, atIndexPath indexPath: IndexPath) {
//        let menuItem = item as? MenuBarItem {
//            menuItem.menuItemWasSelected()
//        }
        
        self.blink(item: item, count: 4)
    }
    
    override func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                              mouseDownAtIndexPath indexPath: IndexPath,
                                              forItem item: NSCollectionViewItem,
                                              withEvent event: NSEvent) {

        self.logger.log("tracking: Handling menu mouseDown")
//        self.handleMenuChoice(atIndexPath: indexPath)
    }

    override func mouseTrackingCollectionView(_ collectionView: MouseTrackingCollectionView,
                                              mouseUpAtIndexPath indexPath: IndexPath,
                                              forItem item: NSCollectionViewItem,
                                              withEvent event: NSEvent) {
        
        self.logger.log("tracking: Handling menu mouseUp")
        self.handleMenuChoice(forItem: item, atIndexPath: indexPath)
    }

    @objc func eventMenuItem(_ sender: Any) {
        
    }
    
    lazy var eventsMenuItem:NSMenuItem = {
        let menuItem = NSMenuItem(title: "Custom", action:#selector(eventMenuItem(_:)), keyEquivalent: "")
        menuItem.view = self.view
        return menuItem
    }()
        
    lazy var menuBarMenu: NSMenu = {
        let menu = NSMenu()
        menu.addItem(self.eventsMenuItem)
        return menu
    }()
    
}
