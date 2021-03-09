//
//  MenuItem.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/8/21.
//

import AppKit
import Foundation

open class MenuItem: NSMenuItem {
    public typealias CompletionBlock = (_ menuItem: NSMenuItem) -> Void

    public var completion: CompletionBlock?

    public private(set) var viewController: NSViewController?

    public init(title: String,
                image: NSImage,
                completion: CompletionBlock? = nil) {
        super.init(title: title,
                   action: #selector(wasChosen(_:)),
                   keyEquivalent: "")

        self.image = image
        self.target = self
        self.completion = completion
    }

    public init(title: String,
                systemSymbolName: String,
                completion: CompletionBlock? = nil) {
        super.init(title: title,
                   action: #selector(wasChosen(_:)),
                   keyEquivalent: "")

        self.image = NSImage(systemSymbolName: systemSymbolName, accessibilityDescription: systemSymbolName)
        self.target = self
        self.completion = completion
    }

    public init(title: String,
                image: NSImage,
                tag: Int,
                completion: CompletionBlock? = nil) {
        super.init(title: title,
                   action: #selector(wasChosen(_:)),
                   keyEquivalent: "")

        self.tag = tag
        self.image = image
        self.target = self
        self.completion = completion
    }

    public init(title: String,
                completion: CompletionBlock? = nil) {
        super.init(title: title,
                   action: #selector(wasChosen(_:)),
                   keyEquivalent: "")

        self.image = image
        self.target = self
        self.completion = completion
    }

    public init(title: String,
                tag: Int,
                completion: CompletionBlock? = nil) {
        super.init(title: title,
                   action: #selector(wasChosen(_:)),
                   keyEquivalent: "")

        self.tag = tag
        self.target = self
        self.completion = completion
    }

    public init(withView view: SDKView,
                completion: CompletionBlock? = nil) {
        super.init(title: "",
                   action: #selector(wasChosen(_:)),
                   keyEquivalent: "")

        self.view = view

        assert(view.frame.size.width > 0 && view.frame.size.height > 0, "preferred content size not set")
    }

    public init(withViewController viewController: NSViewController,
                completion: CompletionBlock? = nil) {
        viewController.resizeToFitInMenu()

        self.viewController = viewController
        super.init(title: "",
                   action: #selector(wasChosen(_:)),
                   keyEquivalent: "")

        self.view = viewController.view
    }

    public required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    @objc func wasChosen(_ sender: NSMenuItem) {
        self.completion?(self)
    }
}

extension NSViewController {
    public func resizeToFitInMenu() {
        var size = self.preferredContentSize

        assert(size.height > 0, "preferred content size not set")

        size.width = 500
        self.preferredContentSize = size

        var frame = self.view.frame
        frame.size = size
        self.view.frame = frame
    }
}
