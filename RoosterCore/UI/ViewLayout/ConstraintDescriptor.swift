//
//  ConstraintDescriptor.swift
//  Rooster
//
//  Created by Mike Fullerton on 10/27/21.
//

#if os(macOS)
import Cocoa
import Foundation
#else
import Foundation
import UIKit
#endif

public struct ConstraintDescriptor {
    public static let center = ConstraintDescriptor(withHorizontalAlignment: .center, verticalAlignment: .center)
    public static let centerTop = ConstraintDescriptor(withHorizontalAlignment: .center, verticalAlignment: .leading)
    public static let centerBottom = ConstraintDescriptor(withHorizontalAlignment: .center, verticalAlignment: .trailing)

    public static let fill = ConstraintDescriptor(withHorizontalAlignment: .fill, verticalAlignment: .fill)
    public static let fillTop = ConstraintDescriptor(withHorizontalAlignment: .fill, verticalAlignment: .leading)
    public static let fillBottom = ConstraintDescriptor(withHorizontalAlignment: .fill, verticalAlignment: .trailing)

    public static let leading = ConstraintDescriptor(withHorizontalAlignment: .leading, verticalAlignment: .center)
    public static let trailing = ConstraintDescriptor(withHorizontalAlignment: .trailing, verticalAlignment: .center)

    public var horizontalAlignment: Alignment
    public var verticalAlignment: Alignment

    init(withHorizontalAlignment horizontalAlignment: Alignment,
         verticalAlignment: Alignment) {
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
    }

    public func constraints(forView view: SDKView) -> [NSLayoutConstraint]? {
        assert(view.superview != nil)

        var constraints: [NSLayoutConstraint] = []

        if let positional = self.positionalConstraints(forView: view) {
            constraints.append(contentsOf: positional)
        }

        if let size = self.sizeConstraints(forView: view) {
            constraints.append(contentsOf: size)
        }

        return constraints
    }
}

extension ConstraintDescriptor {
    public struct Alignment {
        public static let leading = Alignment(withPosition: .leading)
        public static let center = Alignment(withPosition: .center)
        public static let trailing = Alignment(withPosition: .trailing)
        public static let fill = Alignment(withPosition: .fill)

        public enum Position {
            case none
            case leading
            case center
            case trailing
            case fill

            var opposite: Position {
                switch self {
                case .leading:
                    return .trailing

                case .trailing:
                    return .leading

                case .center:
                    return .center

                case .fill:
                    return .fill

                case .none:
                    return .none
                }
            }
        }

        public var position: Position

        public var constant: CGFloat

        public init(withPosition position: Position, constant: CGFloat = 0) {
            self.position = position
            self.constant = constant
        }

        public init() {
            self.position = .none
            self.constant = 0
        }
    }

    public struct Size {
        public static let intrinsic = Size(withBehavior: .intrinsic)

        public enum Behavior {
            case none
            case intrinsic
            case constant
        }

        public var behavior: Behavior

        public var constant: CGFloat

        public init() {
            self.behavior = .none
            self.constant = 0
        }

        public init(withBehavior behavior: Behavior, withConstant constant: CGFloat = 0) {
            self.behavior = behavior
            self.constant = constant
        }
    }

    private func positionalConstraints(forView view: SDKView) -> [NSLayoutConstraint]? {
        guard let superview = view.superview else { return nil }

        var constraints: [NSLayoutConstraint] = []

        switch self.horizontalAlignment.position {
        case .none:
            break

        case .leading:
            constraints.append(view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: self.horizontalAlignment.constant))

        case .trailing:
            constraints.append(view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: self.horizontalAlignment.constant))

        case .center:
            constraints.append(view.centerXAnchor.constraint(equalTo: superview.centerXAnchor, constant: self.horizontalAlignment.constant))

        case .fill:
            constraints.append(view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: self.horizontalAlignment.constant))
            constraints.append(view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: self.horizontalAlignment.constant))
        }

        switch self.verticalAlignment.position {
        case .none:
            break

        case .leading:
            constraints.append(view.topAnchor.constraint(equalTo: superview.topAnchor, constant: self.verticalAlignment.constant))

        case .center:
            constraints.append(view.centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: self.verticalAlignment.constant))

        case .trailing:
            constraints.append(view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: self.verticalAlignment.constant))

        case .fill:
            constraints.append(view.topAnchor.constraint(equalTo: superview.topAnchor, constant: self.horizontalAlignment.constant))
            constraints.append(view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: self.horizontalAlignment.constant))
        }

        return constraints
    }

    private func sizeConstraints(forView view: SDKView) -> [NSLayoutConstraint]? {
        // TODO

        return []
    }
}

extension SDKView {
    public func activateConstraints(_ constraintDescriptor: ConstraintDescriptor) {
        self.translatesAutoresizingMaskIntoConstraints = false

        assert(self.intrinsicContentSize.width > 0, "no intrinsic content width")
        assert(self.intrinsicContentSize.height > 0, "no intrinsic content height")

        if let constraints = constraintDescriptor.constraints(forView: self) {
            NSLayoutConstraint.activate(constraints)
        }
    }
}
