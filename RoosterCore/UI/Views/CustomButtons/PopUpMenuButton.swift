//
//  PopupMenuButton.swift
//  RoosterCore-macOS
//
//  Created by Mike Fullerton on 3/20/21.
//

import Foundation

import Cocoa

open class PopUpMenuButton: Button {
    private var popupMenu: NSMenu?

    public var menuItems: [NSMenuItem]

    public init(image: NSImage,
                menuItems: [NSMenuItem] = []) {
        self.menuItems = menuItems
        super.init(image: image)
    }

    public init(withTitle title: String,
                menuItems: [NSMenuItem] = []) {
        self.menuItems = menuItems
        super.init(title: title)
    }

    public init(withTitle title: String,
                image: NSImage,
                menuItems: [NSMenuItem] = []) {
        self.menuItems = menuItems
        super.init(title: title,
                   image: image)
    }

    public required init?(coder: NSCoder) {
        self.menuItems = []
        super.init(coder: coder)
    }

    public func clearAllMenusStates() {
        self.menuItems.forEach { $0.state = .off }
    }

    override public func handleMouseDown() {
        self.showMenu()
    }

    override public func createMouseEventSource() -> MouseEventSource {
        MouseTrackingView()
    }
}

extension PopUpMenuButton {
    fileprivate func showMenu() {
        guard let event = NSApplication.shared.currentEvent else {
            self.logger.error("Unabled to get event")
            return
        }
        let popupMenu = NSMenu()
        popupMenu.autoenablesItems = false
        popupMenu.items = self.menuItems
        popupMenu.delegate = self
        self.popupMenu = popupMenu
        NSMenu.popUpContextMenu(popupMenu, with: event, for: self)
        self.logger.log("popping up menu")
    }
}

extension PopUpMenuButton: NSMenuDelegate {
    public func menuDidClose(_ menu: NSMenu) {
        assert(menu == self.popupMenu, "got callback for wrong menu")
        self.logger.log("did close popup")
        self.isHighlighted = false
        self.popupMenu = nil
    }

    public func menuNeedsUpdate(_ menu: NSMenu) {
    }

    public func numberOfItems(in menu: NSMenu) -> Int {
        self.menuItems.count
    }

    public func menu(_ menu: NSMenu, update item: NSMenuItem, at index: Int, shouldCancel: Bool) -> Bool {
        false
    }

    public func menuHasKeyEquivalent(_ menu: NSMenu,
                                     for event: NSEvent,
                                     target: AutoreleasingUnsafeMutablePointer<AnyObject?>,
                                     action: UnsafeMutablePointer<Selector?>) -> Bool {
        false
    }

    public func menuWillOpen(_ menu: NSMenu) {
        self.logger.log("will open popup")
    }
}
