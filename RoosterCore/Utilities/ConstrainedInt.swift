//
//  ConstrainedInt.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/11/21.
//

import Foundation

@propertyWrapper
public struct ConstrainedInt: Equatable, CustomStringConvertible {
    private var value: Int
    private var minValue: Int
    private var maxValue: Int

    public init(wrappedValue: Int, maxValue: Int, minValue: Int = 0) {
        self.minValue = minValue
        self.maxValue = maxValue
        self.value = Self.constrain(wrappedValue, min: minValue, max: maxValue)
    }

    private static func constrain(_ value: Int, min: Int, max: Int) -> Int {
        if value < min {
            return min
        } else if value > max {
            return max
        }

        return value
    }

    public var wrappedValue: Int {
        get { self.value }
        set { self.value = Self.constrain(newValue, min: self.minValue, max: self.maxValue) }
    }

    public var description: String {
        "\(self.value)"
    }
}
