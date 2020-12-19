//
//  MenuBarPopover.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/18/20.
//

import Foundation

class MenuBarPopover {
    
    private let popover: MenuBarPopoverProtocol
    
    init() {
        self.popover = AppKitPlugin.instance.createMenuBarPopover()
    }
    
    public var isHidden: Bool {
        get {
            return self.popover.isHidden
        }
        set(hidden) {
            self.popover.isHidden = hidden
        }
    }
}
