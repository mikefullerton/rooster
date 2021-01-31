//
//  File.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/31/21.
//

import Foundation
import AppKit

protocol StopAlarmMenuBarButtonDelegate: AnyObject {
    func stopAlarmMenuBarButtonButtonWasClicked(_ item: StopAlarmMenuBarButton)
}

class StopAlarmMenuBarButton: MenuBarItem, AppControllerAware  {
    
    weak var delegate: StopAlarmMenuBarButtonDelegate?
    
    init(withDelegate delegate: StopAlarmMenuBarButtonDelegate?) {
        super.init()
        self.delegate = delegate
        self.buttonImage = self.redAlarmImage
//        self.contentTintColor = NSColor.systemRed
    }
    
    var alarmImage : NSImage? {
        if let image = NSImage(systemSymbolName:"bell.fill", accessibilityDescription:"Stop Alarms") {
            image.isTemplate = true
            return image
        }
        
        return nil
    }

    var redAlarmImage: NSImage? {
        if let image = self.alarmImage {
            return image.tint(color: NSColor.systemRed)
        }
            
        return nil

    }

    var whiteAlarmImage: NSImage? {
        if let image = self.alarmImage {
            return image.tint(color: NSColor.white)
        }
            
        return nil
    }
    
    @objc override func buttonClicked(_ sender: AnyObject?) {
        if let delegate = self.delegate {
            delegate.stopAlarmMenuBarButtonButtonWasClicked(self)
        }
    }

}
