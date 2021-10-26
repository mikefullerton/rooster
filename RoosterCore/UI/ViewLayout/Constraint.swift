//
//  LayoutDescriptor.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 4/22/21.
//

import Cocoa
import Foundation

public struct Constraint: Identifiable, CustomStringConvertible, Equatable {
    public enum ID: String {
        case leading
        case trailing
        case top
        case bottom
        case center
        case centerX
        case centerY
        case intrinsicSize
        case intrinsicWidth
        case intrinsicHeight
        case fill
        case fillWidth
        case fillHeight
        case width
        case height
        case size
        case beforeSibling
        case afterSibling
        // TODO: Add Baselines
    }

    public let id: ID
    public let size: CGSize
    public let constant: CGFloat
    public var siblingView: SDKView?

    public init(_ id: ID,
                size: CGSize = CGSize.zero,
                constant: CGFloat = 0,
                siblingView: SDKView? = nil) {
        self.id = id
        self.size = size
        self.constant = constant
        self.siblingView = siblingView
    }

    public init(_ id: ID, constant: CGFloat) {
        self.init(id, size: CGSize.zero, constant: constant, siblingView: nil)
    }

    public init(_ id: ID, siblingView: SDKView, constant: CGFloat) {
        self.init(id, size: CGSize.zero, constant: constant, siblingView: siblingView)
    }

    public var description: String {
        """
        \(type(of: self)): \
        id: \(self.id.rawValue), \
        value: \(self.id.rawValue), \
        size: \(String(describing: self.size)), \
        constant: \(self.constant), \
        siblingView: \(String(describing: self.siblingView))
        """
    }

//    public func opposite(_ Constraint: Constraint) -> Constraint {
//        switch self {
//        case .leading:
//            return .trailing
//
//        case .trailing:
//            return .leading
//
//        case .center:
//            return .center
//        }
//    }

}

extension NSView {
    public func addSubview(_ view: NSView,
                           positioned: NSWindow.OrderingMode,
                           relativeTo otherView: NSView?,
                           constraints: [Constraint],
                           insets: SDKEdgeInsets? = nil) {
        self.addSubview(view, positioned: positioned, relativeTo: otherView)
        view.activate(constraints: constraints)
    }

    public func addSubview(_ view: NSView,
                           positioned: NSWindow.OrderingMode,
                           relativeTo otherView: NSView?,
                           constraints: [Constraint.ID],
                           insets: SDKEdgeInsets? = nil) {
        self.addSubview(view,
                        positioned: positioned,
                        relativeTo: otherView,
                        constraints: constraints.map { Constraint($0) },
                        insets: insets)
    }

    public func addSubview(_ view: NSView,
                           constraints: [Constraint],
                           insets: SDKEdgeInsets? = nil) {
        self.addSubview(view)
        view.activate(constraints: constraints, insets: insets)
    }

    public func addSubview(_ view: NSView,
                           constraints: [Constraint.ID],
                           insets: SDKEdgeInsets? = nil) {
        self.addSubview(view,
                        constraints: constraints.map { Constraint($0) },
                        insets: insets)
    }

    public func activate(constraints: [Constraint],
                         insets: SDKEdgeInsets? = nil) {
        self.translatesAutoresizingMaskIntoConstraints = false

        let constraints = self.layoutConstraints(withConstraints: constraints,
                                                 insets: insets)
        if !constraints.isEmpty {
            NSLayoutConstraint.activate(constraints)
        }
    }

    public func activate(constraints: [Constraint.ID],
                         insets: SDKEdgeInsets? = nil) {
        self.translatesAutoresizingMaskIntoConstraints = false

        let constraints = self.layoutConstraints(withConstraints: constraints.map { Constraint($0) },
                                                 insets: insets)
        if !constraints.isEmpty {
            NSLayoutConstraint.activate(constraints)
        }
    }

    // swiftlint:disable cyclomatic_complexity function_body_length

    public func layoutConstraints(withConstraints constraints: [Constraint],
                                  insets: SDKEdgeInsets? = nil) -> [NSLayoutConstraint] {
        var layoutConstraints: [NSLayoutConstraint] = []
        let insets = insets ?? SDKEdgeInsets.zero

        for constraint in constraints {
            guard let view = constraint.siblingView != nil ? constraint.siblingView: self.superview else {
                assertionFailure("no view for constraints")
                return []
            }

            switch constraint.id {
            case .leading:
                layoutConstraints.append(self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left + constraint.constant))

            case .trailing:
                layoutConstraints.append(self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right - constraint.constant))

            case .top:
                layoutConstraints.append(self.topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top + constraint.constant))

            case .bottom:
                layoutConstraints.append(self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom - constraint.constant))

            case .fill:
                layoutConstraints.append(self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left + constraint.constant))
                layoutConstraints.append(self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right - constraint.constant))
                layoutConstraints.append(self.topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top + constraint.constant))
                layoutConstraints.append(self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom - constraint.constant))

            case .fillWidth:
                layoutConstraints.append(self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left + constraint.constant))
                layoutConstraints.append(self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right - constraint.constant))

            case .fillHeight:
                layoutConstraints.append(self.topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top + constraint.constant))
                layoutConstraints.append(self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom - constraint.constant))

            case .centerX:
                layoutConstraints.append(self.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: constraint.constant))

            case .centerY:
                layoutConstraints.append(self.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constraint.constant))

            case .center:
                layoutConstraints.append(self.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: constraint.constant))
                layoutConstraints.append(self.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constraint.constant))

            case .intrinsicWidth:
                layoutConstraints.append(self.widthAnchor.constraint(equalToConstant: self.intrinsicContentSize.width + constraint.constant))

            case .intrinsicHeight:
                layoutConstraints.append(self.heightAnchor.constraint(equalToConstant: self.intrinsicContentSize.height + constraint.constant))

            case .intrinsicSize:
                layoutConstraints.append(self.widthAnchor.constraint(equalToConstant: self.intrinsicContentSize.width + constraint.constant))
                layoutConstraints.append(self.heightAnchor.constraint(equalToConstant: self.intrinsicContentSize.height + constraint.constant))

            case .width:
                layoutConstraints.append(self.widthAnchor.constraint(equalToConstant: constraint.size.width + constraint.constant))

            case .height:
                layoutConstraints.append(self.heightAnchor.constraint(equalToConstant: constraint.size.height + constraint.constant))

            case .size:
                layoutConstraints.append(self.widthAnchor.constraint(equalToConstant: constraint.size.width + constraint.constant))
                layoutConstraints.append(self.heightAnchor.constraint(equalToConstant: constraint.size.height + constraint.constant))

            case .beforeSibling:
                layoutConstraints.append(self.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: -constraint.constant))

            case .afterSibling:
                layoutConstraints.append(self.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: constraint.constant))
            }
        }

        return layoutConstraints
    }
}
