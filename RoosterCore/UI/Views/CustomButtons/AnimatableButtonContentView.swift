//
//  AnimatableButtonContentView.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/6/21.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

open class AnimatableButtonContentView: AnimateableView, AbstractButtonContentView, Highlightable {
    private var index: Int = 0

    private weak var button: Button?

    public func wasAdded(toButton button: Button) {
        self.button = button
    }

    public func updateForPosition(_ position: SDKView.Position, inButton button: Button) {
        if let currentView = self.currentView {
            self.updateCurrentViewConstraints(currentView)
        }
    }

    public var isHighlighted = false {
        didSet { self.setVisibleState(forView: self.currentView) }
    }

    public var isEnabled = true {
        didSet { self.setVisibleState(forView: self.currentView) }
    }

    private func setVisibleState(forView view: SDKView?) {
        if let control = view as? NSControl {
            control.isEnabled = self.isEnabled
            control.isHighlighted = self.isHighlighted && self.isEnabled
        }
    }

    public func updateConstraints(forLayoutInButton button: Button) {
    }

    public var contentViews: [SDKView] = [] {
        didSet {
            self.viewIndex = self.contentViews.isEmpty ? -1 : 0
        }
    }

    public var viewIndex: Int {
        get {
            self.index
        }
        set(index) {
            guard index >= 0 && index < self.contentViews.count else {
                return
            }

            self.index = index
            self.currentView = self.contentViews[index]
        }
    }

    public var maxViewIndex: Int {
        self.contentViews.count - 1
    }

    public private(set) var currentView: SDKView? {
        didSet {
            if oldValue != self.currentView {
                if let previous = oldValue {
                    previous.removeFromSuperview()
                }

                if let current = self.currentView {
                    self.addSubview(current)
                    self.setVisibleState(forView: current)
                    self.updateCurrentViewConstraints(current)
                }
            }
        }
    }

    private func updateCurrentViewConstraints(_ view: SDKView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        if let button = self.button {
            view.deactivatePositionalContraints()
            view.activateConstraint(forPosition: button.contentViewPosition)
        }
    }

    public var viewCount: Int {
        self.contentViews.count
    }

    override public var intrinsicContentSize: CGSize {
        var maxAspectRatio: CGFloat = 0
        var maxSize = CGSize.zero

        for imageView in self.contentViews {
            let size = imageView.intrinsicContentSize

            let aspectRatio = size.width / size.height

            if maxAspectRatio < aspectRatio {
                maxAspectRatio = aspectRatio
            }

            if size.width > maxSize.width {
                maxSize.width = size.width
            }

            if size.height > maxSize.height {
                maxSize.height = size.height
            }
        }

        let outSize = CGSize(width: maxSize.height * maxAspectRatio,
                             height: maxSize.height + 10)

        return outSize
    }

    public func setNextAnimatableView() {
        var index = self.viewIndex + 1
        if index > self.maxViewIndex {
            index = 0
        }

        self.viewIndex = index
    }
}
