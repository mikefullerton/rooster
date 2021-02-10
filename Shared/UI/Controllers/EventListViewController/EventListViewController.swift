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

class EventListViewController : CalendarItemTableViewController<EventListViewModel> {
   
    let minimumContentSize = CGSize(width: 400, height: 80)
    
    private func adjustedSize(_ size: CGSize) -> CGSize {
        return  CGSize(width: max(self.minimumContentSize.width, size.width),
                       height: max(self.minimumContentSize.height, size.height))
    }
   
    override func provideDataModel() -> EventListViewModel? {
        return EventListViewModel(withEvents: AppDelegate.instance.dataModelController.dataModel.events,
                                  reminders: AppDelegate.instance.dataModelController.dataModel.reminders)
    }
    
    override var preferredContentSize: CGSize {
        get {
            return self.adjustedSize(super.preferredContentSize)
        }
        set(size) {
//            if self.preferredContentSize != size {
//                super.preferredContentSize = size
//
//                if self.view.window != nil {
//                    self.logger.log("Adjusting window size to: \(NSStringFromSize(size))")
//
//                    self.view.invalidateIntrinsicContentSize()
//
//                    self.sendSizeChangedEvent()
//                }
//            }
        }
    }
}
