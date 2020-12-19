//
//  MenubarPopover.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/18/20.
//

import Foundation
import AppKit
import SwiftUI

extension AppKitPlugin {
    public class MenuBarPopover: NSObject, MenuBarPopoverProtocol {
        let popover: NSPopover
        let contentView: ContentView
        let statusBarItem: NSStatusItem
        
        public override init() {
            
            let contentView = ContentView()
            
            let popover = NSPopover()
            popover.contentSize = NSSize(width: 400, height: 400)
            popover.behavior = .transient
            popover.contentViewController = NSHostingController(rootView: contentView)
            
            let statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        
            if let button = statusBarItem.button {
                button.image = NSImage(named: "Icon")
                button.action = #selector(togglePopover(_:))
            }
            
            self.contentView = contentView
            self.statusBarItem = statusBarItem
            self.popover = popover
        }
        
        @objc func togglePopover(_ sender: AnyObject?) {
            self.isHidden = !self.isHidden
        }
        
        public var isHidden: Bool {
            get {
                return !self.popover.isShown
            }
            set(hidden) {
                if let button = self.statusBarItem.button {
                    if hidden && self.popover.isShown {
                        self.popover.performClose(self)
                    } else if !hidden && !self.popover.isShown {
                        self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                    }
                }

            }
        }
    }
}
