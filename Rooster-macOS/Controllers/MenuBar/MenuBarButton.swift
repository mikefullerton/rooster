//
//  MenuBarButton.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/14/21.
//

import Foundation
import RoosterCore

public class MenuBarButton: NSObject, Loggable {
    private lazy var buttonView: MenuBarButtonView = {
        let view = MenuBarButtonView()
        view.delegate = self
        return view
    }()

    public var contentTintColor: NSColor? {
        get { self.buttonView.contentTintColor }
        set { self.buttonView.contentTintColor = newValue }
    }

    public var buttonTitle: String {
        get { self.buttonView.title }
        set { self.buttonView.title = newValue }
    }

    private lazy var statusBarItem: NSStatusItem = {
        let statusBarItem = NSStatusBar.system.statusItem(withLength: 40)

        if let button = statusBarItem.button {
            button.isTransparent = true
            button.isEnabled = false
            button.image = NSImage.transparentImage(ofSize: CGSize(width: 40, height: 18))

            let view = self.buttonView
            button.addSubview(view)
            view.activateFillInParentConstraints()
        }

        return statusBarItem
    }()

    public var isVisible: Bool {
        get {
            self.statusBarItem.isVisible
        }
        set {
            self.statusBarItem.isVisible = newValue
        }
    }
}

extension MenuBarButton: MenuBarButtonViewDelegate {
    public func menuBarButtonViewContentDidChange(_ menuBarButtonView: MenuBarButtonView) {
        let width = menuBarButtonView.intrinsicContentSize.width
        self.statusBarItem.button?.image = NSImage.transparentImage(ofSize: CGSize(width: width, height: 18))
        self.statusBarItem.length = width
    }
}
