//
//  MenubarPopover.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/18/20.
//

import Foundation
import AppKit
import SwiftUI

extension NSImage {
    func tint(color: NSColor) -> NSImage {
        let image = self.copy() as! NSImage
        image.lockFocus()

        color.set()

        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceAtop)

        image.unlockFocus()
        image.size = self.size
        
        return image
    }
}


@objc class MenuBarPopover: NSObject, MenuBarPopoverProtocol {
    
    var delegate: MenuBarPopoverProtocolDelegate?
    
    private var statusBarItem: NSStatusItem? = nil
    
    var redRoosterImage : NSImage? {
        if let image = Bundle(for: type(of: self)).image(forResource: NSImage.Name("RedRoosterIcon")) {
            
            return image
        }
        
        return nil
    }
    
    var defaultRoosterImage: NSImage? {
        if let image = self.redRoosterImage {
            image.isTemplate = true
            return image.tint(color: NSColor.white)
        }
            
        return nil
    }
    
    func setStatusBarIconImage(_ inImage: NSImage?) {
        if let image = inImage,
           let statusBarItem = self.statusBarItem,
           let button = statusBarItem.button {
           
            image.size = CGSize(width: 26, height: 26)
            button.image = image
        }
    }
    
    func showInMenuBar() {
        let statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.squareLength))
        
        if let button = statusBarItem.button,
           let image = self.defaultRoosterImage {
            
            image.size = CGSize(width: 26, height: 26)
            button.image = image
            button.action = #selector(buttonClicked(_:))
            button.target = self
        
            button.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        }
        
        self.statusBarItem = statusBarItem
    }

    @objc func buttonClicked(_ sender: AnyObject?) {
        if let delegate = self.delegate {
            delegate.menuBarButtonWasClicked(self)
        }
    }
    
    lazy var popoverViewController : NSViewController = {
        return MenuBarPopoverViewController()
    }()
    

    lazy var popover : NSPopover = {
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 400)
        popover.behavior = .transient
        popover.contentViewController = self.popoverViewController
        return popover
    }()
    
    var isPopoverHidden: Bool {
        get {
            return !self.popover.isShown
        }
        set(hidden) {
            if let button = self.statusBarItem?.button {
                if hidden && self.popover.isShown {
                    self.popover.performClose(self)
                } else if !hidden && !self.popover.isShown {
                    self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                }
            }

        }
    }
    
    var _isAlarmFiring = false
    
    var isAlarmFiring: Bool {
        
        get {
            return _isAlarmFiring
        }
        
        set(firing) {
            if firing != _isAlarmFiring {
                _isAlarmFiring = firing
                
                if _isAlarmFiring {
                    self.setStatusBarIconImage(self.redRoosterImage)
                } else {
                    self.setStatusBarIconImage(self.defaultRoosterImage)
                }
            }
        }
    }
}
