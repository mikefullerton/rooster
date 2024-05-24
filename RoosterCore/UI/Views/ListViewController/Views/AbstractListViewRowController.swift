//
//  AbstractListViewRowView.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/24/21.
//

import Foundation
#if os(macOS)
import Cocoa
import AppKit
#else
import UIKit
#endif

open class AbstractListViewRowController: SDKCollectionViewItem, Loggable {
    open class func preferredSize(forContent content: Any?) -> CGSize {
        CGSize.zero
    }

    override open var highlightState: NSCollectionViewItem.HighlightState {
        get { super.highlightState }
        set(state) {
            if !self.isHighlightable {
                super.highlightState = .none
                return
            }

            super.highlightState = state

            switch state {
            case .none:
                self.highlightBackgroundView?.isHidden = true

            case .forSelection:
                self.highlightBackgroundView?.isHidden = false

            case .forDeselection:
                self.highlightBackgroundView?.isHidden = false

            case .asDropTarget:
                self.highlightBackgroundView?.isHidden = false

            @unknown default:
                self.highlightBackgroundView?.isHidden = true
            }

//            print("tracking: highlight state: \(state.rawValue), \(Date().shortDateAndLongTimeString), \(self.highlightBackgroundView)")

            self.view.needsDisplay = true
        }
    }

    public var isHighlightable = false {
        didSet {
            if self.isHighlightable && self.highlightBackgroundView == nil {
                self.addHighlightBackgroundView()
            }
        }
    }

    public private(set) var highlightBackgroundView: NSVisualEffectView?

    public func createBlendingBackgroundViewWithColor(_ color: SDKColor) -> SDKView {
        let view = NSVisualEffectView()
        view.state = .active
        view.material = .headerView
        view.isEmphasized = false
        view.blendingMode = .behindWindow

        return view
    }

    public func addHighlightBackgroundView() {
        let view = NSVisualEffectView()
        view.state = .active
        view.material = .selection
        view.isEmphasized = true
        view.blendingMode = .behindWindow
        self.highlightBackgroundView = view

        let subviews = self.view.subviews
        if !subviews.isEmpty {
            self.view.addSubview(view, positioned: .below, relativeTo: subviews[0] )
        } else {
            self.view.addSubview(view)
        }

        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true

        self.setConstraintsForHighlightBackgroundView()
    }

    open func setConstraintsForHighlightBackgroundView() {
        if let view = self.highlightBackgroundView {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                view.topAnchor.constraint(equalTo: self.view.topAnchor),
                view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }

    override open var isSelected: Bool {
        get {
            super.isSelected
        }
        set(selected) {
            super.isSelected = selected

            if selected {
                if self.highlightBackgroundView == nil {
                    self.addHighlightBackgroundView()
                }

                self.highlightBackgroundView?.isHidden = false
            } else {
                self.highlightBackgroundView?.isHidden = true
            }
        }
    }

    public var rowView: RowView {
        // swiftlint:disable force_cast
        self.view as! RowView
        // swiftlint:enable force_cast
    }

    override open func loadView() {
        let view = RowView()
        self.view = view
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

//        self.preferredContentSize = Self.preferredSize(forContent: nil)
//        CGSize(width: NSView.noIntrinsicMetric, height: Self.preferredHeight)
    }

    override open var preferredContentSize: NSSize {
        get {
            let size = super.preferredContentSize
            return size
        }
        set(newSize) {
            super.preferredContentSize = newSize
            self.rowView.preferredSize = newSize
        }
    }

    override open func preferredLayoutAttributesFitting(
        _ layoutAttributes: NSCollectionViewLayoutAttributes) -> NSCollectionViewLayoutAttributes {
        if let collectionView = self.collectionView {
            var frame = layoutAttributes.frame

            var size = self.preferredContentSize
            size.width = collectionView.bounds.size.width

            frame.size = size
            frame.origin.x = collectionView.bounds.minX

            layoutAttributes.frame = frame
            layoutAttributes.size = size
        }

        return layoutAttributes
    }
}

extension AbstractListViewRowController {
    open class RowView: NSView {
        open var preferredSize: CGSize? {
            didSet {
                self.invalidateIntrinsicContentSize()
            }
        }

        override open var intrinsicContentSize: CGSize {
            if let preferredSize = self.preferredSize {
                return preferredSize
            }

            return super.intrinsicContentSize
        }
    }
}
