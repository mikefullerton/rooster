//
//  PopupMenu.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/8/21.
//

import AppKit
import Foundation

open class PopupMenu: NSObject, Loggable {
    public typealias Callback = (_ menu: PopupMenu) -> Void

    public var completion: Callback?

    open var representedObject: Any? {
        didSet {
            self.menuItems.forEach { $0.representedObject = self.representedObject }
        }
    }

    private var menu: NSMenu?

    public var menuItems: [NSMenuItem]

    public init(menuItems: [NSMenuItem] = []) {
        self.menuItems = menuItems
    }

    public func clearAllMenusStates() {
        self.menuItems.forEach { $0.state = .off }
    }

    public func setMenuState( _ state: NSControl.StateValue, forMenuItemAtIndex index: Int) {
        guard index < self.menuItems.count else {
            return
        }

        self.menuItems[index].state = state
    }

    public func setExclusiveMenuState( _ state: NSControl.StateValue, forMenuItemAtIndex index: Int) {
        guard index < self.menuItems.count else {
            return
        }

        self.clearAllMenusStates()
        self.menuItems[index].state = state
    }

    private func createMenu() -> NSMenu {
        let menu = NSMenu()

//        var newMenuItems: [NSMenuItem] = []
//
//        for item in self.menuItems {
//            if let newItem = item.copy() as? MenuItem {
//                newItem.representedObject = self.representedObject
//                newMenuItems.append(newItem)
//            }
//        }

        menu.items = self.menuItems
        menu.delegate = self
        return menu
    }

    public func show(forView view: SDKView, completion: Callback? = nil) {
        guard let event = NSApplication.shared.currentEvent else {
            self.logger.error("Unabled to get event")
            return
        }
        let menu = self.createMenu()
        self.menu = menu
        self.completion = completion

        NSMenu.popUpContextMenu(menu, with: event, for: view)
    }
}

extension PopupMenu: NSMenuDelegate {
    public func menuDidClose(_ menu: NSMenu) {
        assert(menu == self.menu, "got callback for wrong menu")
        self.completion?(self)
        self.menu = nil
    }
}
