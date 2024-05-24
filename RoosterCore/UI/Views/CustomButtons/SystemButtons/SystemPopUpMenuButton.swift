//
//  PopupMenuButton.swift
//  RoosterCore-macOS
//
//  Created by Mike Fullerton on 3/20/21.
//

import Foundation

import Cocoa
import AppKit

open class SystemPopUpMenuButton: NSPopUpButton {
    public typealias Callback = (_ button: SystemPopUpMenuButton) -> Void

    public var callback: Callback?

    public var preferredContentSize: CGSize?

    public var menuItems: [NSMenuItem] = [] {
        didSet {
            if self.menu == nil {
                self.menu = NSMenu()
            }

            self.menu?.items = self.menuItems
        }
    }

    public init(withMenuItemTitles titles: [String],
                callback: @escaping Callback) {
        self.callback = callback
        super.init(frame: CGRect.zero, pullsDown: false)

        self.addItems(withTitles: titles)

        self.target = self
        self.action = #selector(menuDidChange(_:))
    }

    public init() {
        super.init(frame: CGRect.zero, pullsDown: false)
        self.target = self
        self.action = #selector(menuDidChange(_:))
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func menuDidChange(_ sender: SystemPopUpMenuButton) {
        self.callback?(self)
    }

    public init(image: NSImage,
                menuItems items: [NSMenuItem] = []) {
        super.init(frame: CGRect.zero, pullsDown: true)
        self.image = image

        let menu = NSMenu()
        menu.items = items
        self.menu = menu
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

    override open var intrinsicContentSize: CGSize {
        guard let preferredContentSize = self.preferredContentSize else {
            return super.intrinsicContentSize
        }

        let outSize = preferredContentSize

//        outSize.width += self.contentInsets.left + self.contentInsets.right
//        outSize.height += self.contentInsets.top + self.contentInsets.bottom

        return outSize
    }
}

/*
extension PopupMenuButton {
}

extension PopupMenuButton: NSMenuDelegate {
    public func menuDidClose(_ menu: NSMenu) {
        assert(menu == self.popupMenu, "got callback for wrong menu")
        self.isHighlighted = false
        self.popupMenu = nil
    }
}
*/
