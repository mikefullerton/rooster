//
//  String+Utilities.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation

extension String {
    public func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(self.suffix(toLength))
        }
    }

    public func prepend(with character: Character, count: Int) -> String {
        String(repeatElement(character, count: count)) + self
    }

    public static var guid: String {
        UUID().uuidString
    }
}

extension Array where Element: CustomStringConvertible {
    public var joinedDescription: String {
        self.map { $0.description }.joined(separator: ", ")
    }
}

public protocol ShortCustomStringConvertable {
    var shortDescription: String { get }
}

extension Array where Element: ShortCustomStringConvertable {
    public var joinedDescription: String {
        self.map { $0.shortDescription }.joined(separator: ", ")
    }
}
