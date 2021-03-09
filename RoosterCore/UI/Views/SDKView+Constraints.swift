//
//  SDKView+Constraints.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/21/21.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

extension SDKView {
    public enum Position {
        case left
        case right
        case center

        var opposite: Position {
            switch self {
            case .left:
                return .right

            case .right:
                return .left

            case .center:
                return .center
            }
        }
    }

    public var debugConstraintDescriptions: [String] {
        var outList: [String] = []

        for constraint in self.constraints {
            outList.append("\(String(describing: constraint)), first anchor: \(String(describing: constraint.firstAnchor))")
        }

        return outList
//            String(describing: outList)
    }

    public func constraint<AnchorType: AnyObject>(forAnchor anchor: NSLayoutAnchor<AnchorType>) -> NSLayoutConstraint? {
        if let index = self.constraints.firstIndex(where: { $0.firstAnchor == anchor }) {
            return self.constraints[index]
        }

        if let superview = self.superview,
           let index = superview.constraints.firstIndex(where: { $0.firstAnchor == anchor }) {
            return superview.constraints[index]
        }

        return nil
    }

    public func deactivateConstraint<AnchorType: AnyObject>(forAnchor anchor: NSLayoutAnchor<AnchorType>) {
        if let constraint = self.constraint(forAnchor: anchor) {
            constraint.isActive = false
        }
    }

    public func deactivateConstraints(forAnchors anchors: [NSObject]) {
        var deactivate: [NSLayoutConstraint] = []
        for object in anchors {
            if let anchor = object as? NSLayoutXAxisAnchor {
               if let constraint = self.constraint(forAnchor: anchor) {
                    deactivate.append(constraint)
               }
            } else if let anchor = object as? NSLayoutYAxisAnchor {
                if let constraint = self.constraint(forAnchor: anchor) {
                    deactivate.append(constraint)
                }
            } else if let anchor = object as? NSLayoutDimension {
                if let constraint = self.constraint(forAnchor: anchor) {
                    deactivate.append(constraint)
                }
            } else {
                assertionFailure("Unknown type of constraint: \(String(describing: object))")
            }
        }

        if !deactivate.isEmpty {
            NSLayoutConstraint.deactivate(deactivate)
        }
    }

    public func deactivatePositionalContraints() {
        self.deactivateConstraints(forAnchors: [
            self.centerYAnchor,
            self.centerXAnchor,
            self.leadingAnchor,
            self.trailingAnchor,
            self.topAnchor,
            self.bottomAnchor
        ])
    }

    public func activateConstraint(forPosition position: Position) {
        assert(self.superview != nil)
        guard let superview = self.superview else { return }

        var activate: [NSLayoutConstraint] = []

        self.translatesAutoresizingMaskIntoConstraints = false

        assert(self.intrinsicContentSize.width > 0, "no intrinsic content width")
        assert(self.intrinsicContentSize.height > 0, "no intrinsic content height")

        switch position {
        case .left:
            activate = [
                self.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
                self.leadingAnchor.constraint(equalTo: superview.leadingAnchor)
            ]

        case .right:
            activate = [
                self.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
                self.trailingAnchor.constraint(equalTo: superview.trailingAnchor)
            ]

        case .center:
            activate = [
                self.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                self.centerYAnchor.constraint(equalTo: superview.centerYAnchor)
            ]
        }

//        constraints.forEach { $0.priority = .required }

        NSLayoutConstraint.activate(activate)
    }

    public func activateIntrinsicSizeConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        assert(self.intrinsicContentSize.width > 0, "no intrinsic content width")
        assert(self.intrinsicContentSize.height > 0, "no intrinsic content height")

        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: self.intrinsicContentSize.height),
            self.widthAnchor.constraint(equalToConstant: self.intrinsicContentSize.width)
        ])
    }

    public func activateCenteredInSuperviewConstraints(offsets: CGPoint = CGPoint.zero) {
        assert(self.superview != nil)
        guard let superview = self.superview else { return }

        assert(self.intrinsicContentSize.width > 0, "no intrinsic content width")
        assert(self.intrinsicContentSize.height > 0, "no intrinsic content height")

        self.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: offsets.y),
            self.centerXAnchor.constraint(equalTo: superview.centerXAnchor, constant: offsets.x)
        ])
    }

    public func activateFillInParentConstraints(insets: SDKEdgeInsets = SDKEdgeInsets.zero) {
        assert(self.superview != nil)
        guard let superview = self.superview else { return }

        self.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: insets.left),
            self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: -insets.right),
            self.topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom)
        ])
    }
}
