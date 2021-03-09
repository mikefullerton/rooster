//
//  AbstractEquatable.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/12/21.
//

import Foundation

public protocol AbstractEquatable {
    func isEqual(to scheduleItem: AbstractEquatable) -> Bool
}

extension Array {
    public func isEqual(to otherAbstractEquatableArray: Self) -> Bool {
        guard self.count == otherAbstractEquatableArray.count else {
            return false
        }

        for i in 0..<self.count {
            guard let item = self[i] as? AbstractEquatable else {
                assertionFailure("expecting Abstract Equatable in array")
                return false
            }

            guard let otherItem = otherAbstractEquatableArray[i] as? AbstractEquatable else {
                assertionFailure("expecting Abstract Equatable in array")
                return false
            }

            if !item.isEqual(to: otherItem) {
                return false
            }
        }
        return true
    }

    public static func areEqual<T: AbstractEquatable>(_ lhs: [T], _ rhs: [T]) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }

        for i in 0..<lhs.count {
            if !lhs[i].isEqual(to: rhs[i]) {
                return false
            }
        }

        return true
    }
}
