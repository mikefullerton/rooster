//
//  PopupMenuButton.swift
//  RoosterCore-macOS
//
//  Created by Mike Fullerton on 3/20/21.
//

import Foundation

import Cocoa
import AppKit

open class PopUpMenuButton: Button {
    private var popupMenu: NSMenu?

    public var menuItems: [NSMenuItem]

    public private(set) var label: SDKTextField?

    public init(image: NSImage,
                menuItems: [NSMenuItem] = []) {
        self.menuItems = menuItems

        super.init(title: nil,
                   attributedTitle: nil,
                   image: image,
                   imagePosition: .center,
                   textPosition: .center,
                   spacing: 0,
                   target: nil,
                   action: nil,
                   callback: nil)
    }

    public init(withTitle title: String,
                menuItems: [NSMenuItem] = []) {
        self.menuItems = menuItems
        super.init(title: title,
                   attributedTitle: nil,
                   image: nil,
                   imagePosition: .center,
                   textPosition: .center,
                   spacing: 0,
                   target: nil,
                   action: nil,
                   callback: nil)
    }

    public init(withTitle title: String,
                image: NSImage,
                menuItems: [NSMenuItem] = []) {
        self.menuItems = menuItems
        super.init(title: title,
                   attributedTitle: nil,
                   image: image,
                   imagePosition: .center,
                   textPosition: .center,
                   spacing: 0,
                   target: nil,
                   action: nil,
                   callback: nil)
    }

    public required init?(coder: NSCoder) {
        self.menuItems = []
        super.init(coder: coder)
    }

    public convenience init(systemSymbolName name: String,
                            accessibilityDescription: String?,
                            menuItems: [NSMenuItem] = []) {
        let image = NSImage.image(withSystemSymbolName: name,
                                  accessibilityDescription: accessibilityDescription,
                                  symbolConfiguration: nil)

        assert(image != nil, "image for symbol name \(name) is nil")

        self.init(image: image!,
                  menuItems: menuItems)
    }

    public convenience init(systemSymbolName name: String,
                            accessibilityDescription: String?,
                            symbolConfiguration: NSImage.SymbolConfiguration,
                            menuItems: [NSMenuItem] = []) {
        let image = NSImage.image(withSystemSymbolName: name,
                                  accessibilityDescription: accessibilityDescription,
                                  symbolConfiguration: symbolConfiguration)

        assert(image != nil, "image for symbol name \(name) is nil")

        self.init(image: image!,
                  menuItems: menuItems)
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

    public var firstSelectedItem: NSMenuItem? {
        for menuItem in self.menuItems where menuItem.state == .on {
            return menuItem
        }

        return nil
    }

    public func addLabel(title: String) {
        let label = HighlightableTextField()
        label.isEditable = false
        label.drawsBackground = false
        label.isBordered = false
        label.stringValue = title

        label.translatesAutoresizingMaskIntoConstraints = false
        if !self.subviews.isEmpty {
            self.addSubview(label, positioned: .below, relativeTo: self.subviews[0])
        } else {
            self.addSubview(label)
        }

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])

        self.contentViewPosition = .trailing

        self.label = label

        self.updateContentViewConstraints()

        self.invalidateIntrinsicContentSize()
    }

    override open var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize

        if let label = self.label {
            size.width += label.intrinsicContentSize.width
        }

        return size
    }
}

extension PopUpMenuButton {
    fileprivate func showMenu() {
        guard !self.menuItems.isEmpty else {
            self.logger.error("No menu items")
            return
        }

        let popupMenu = NSMenu()
        popupMenu.autoenablesItems = false
        popupMenu.items = self.menuItems
        popupMenu.delegate = self
        self.popupMenu = popupMenu

        var popupPoint = CGPoint(x: 0, y: self.bounds.maxY)
        if let label = self.label {
            popupPoint.x = label.frame.maxX
        }

        if let firstSelected = self.firstSelectedItem {
            popupMenu.popUp(positioning: firstSelected, at: popupPoint, in: self)
        } else {
            popupMenu.popUp(positioning: self.menuItems[0], at: popupPoint, in: self)
        }

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
