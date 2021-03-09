//
//  CalendarWindow.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/1/21.
//

import Cocoa
import RoosterCore


class CalendarWindow: WindowController {

    static private weak var instance: CalendarWindow?
    
    @IBOutlet var viewController: CalendarChooserViewController?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.autosaveKey = "Calendars"
        
        if let viewController = self.viewController {
            self.setContentViewController(viewController)
            
//            if let window = self.window {
//                let preferredContentSize = viewController.preferredContentSize
//                self.logger.log("Updating prefs window size: \(NSStringFromSize(preferredContentSize))")
//                window.setContentSize(preferredContentSize)
//            }
        }
    }
        
    static func show() {
        if let windowController = CalendarWindow.instance,
           let window = windowController.window {
            window.makeKeyAndOrderFront(self)
        } else {
            let windowController = CalendarWindow()
            self.instance = windowController
            
            windowController.showWindow(self)
            
        }
    }
}
