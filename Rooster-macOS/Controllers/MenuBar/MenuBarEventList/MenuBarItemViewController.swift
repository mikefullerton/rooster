//
//  EventListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

open class MenuBarItemViewController: CalendarItemListViewController<MenuBarMenuViewModel> {
    override open func provideDataModel() -> MenuBarMenuViewModel? {
        MenuBarMenuViewModel(withSchedule: CoreControllers.shared.scheduleController.schedule)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.view.sdkLayer.backgroundColor = NSColor.clear.cgColor
        self.collectionView.backgroundColors = [ .clear ]
        self.scrollView.drawsBackground = false
        self.scrollView.contentView.drawsBackground = false

        self.collectionView.isMouseTrackingEnabled = true
    }

    override open var preferredContentSize: NSSize {
        get { super.preferredContentSize }
        set(size) {
            super.preferredContentSize = size
            var frame = self.view.frame
            frame.size = self.preferredContentSize
            self.view.frame = frame
        }
    }

//    func blink(item: SDKCollectionViewItem, countdown: Int) {
//        let delay = 75
//
//        if countdown == 0 {
//            if let menu = self.scrollView.enclosingMenuItem?.menu {
//                menu.cancelTrackingWithoutAnimation()
//            }
//
//            if let menuItem = item as? MenuBarItem {
//                menuItem.menuItemWasSelected()
//            } else {
//                self.logger.error("tracking: failed to cast \(item) to menuItem")
//            }
//        } else {
//            item.highlightState = item.highlightState == .forSelection ? .none : .forSelection
//            item.view.needsDisplay = true
//
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(delay)) {
//                self.blink(item: item, countdown: countdown - 1)
//            }
//        }
//    }
}
