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

    public func removeLocationContraints() {
        var deactivate: [NSLayoutConstraint] = []

        self.translatesAutoresizingMaskIntoConstraints = false

        self.constraints.forEach { constraint in
            if  constraint.firstAnchor == self.centerYAnchor ||
                constraint.firstAnchor == self.centerXAnchor ||
                constraint.firstAnchor == self.leadingAnchor ||
                constraint.firstAnchor == self.trailingAnchor ||
                constraint.firstAnchor == self.topAnchor ||
                constraint.firstAnchor == self.bottomAnchor {
                deactivate.append(constraint)
            }
        }

        if !deactivate.isEmpty {
            NSLayoutConstraint.deactivate(deactivate)
        }
    }

    public func setPositionalContraints(forSubview view: NSView,
                                        alignment: Position) {
        view.removeLocationContraints()

        var activate: [NSLayoutConstraint] = []

        switch alignment {
        case .left:
            activate = [
                view.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                view.leadingAnchor.constraint(equalTo: self.leadingAnchor)
            ]

        case .right:
            activate = [
                view.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            ]

        case .center:
            activate = [
                view.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                view.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ]
        }

//        constraints.forEach { $0.priority = .required }

        NSLayoutConstraint.activate(activate)
    }

    public func setIntrinsicSizeConstraints(forSubview view: NSView) {
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: view.intrinsicContentSize.height),
            view.widthAnchor.constraint(equalToConstant: view.intrinsicContentSize.width)
        ])
    }

    public func setCenteredInParentConstraints(forSubview view: NSView,
                                               offsets: CGPoint = CGPoint.zero) {
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: offsets.y),
            view.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: offsets.x)
        ])
    }

    public func setFillInParentConstraints(forSubview view: NSView,
                                           insets: SDKEdgeInsets = SDKEdgeInsets.zero) {
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: insets.left),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -insets.right),
            view.topAnchor.constraint(equalTo: self.topAnchor, constant: insets.top),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -insets.bottom)
        ])
    }
}
