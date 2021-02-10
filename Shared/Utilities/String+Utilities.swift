//
//  String+Utilities.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation

extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(self.suffix(toLength))
        }
    }

    func prepend(with character: Character, count: Int) -> String {
        return String(repeatElement(character, count: count)) + self
    }
    
    static var guid: String {
        return UUID().uuidString
    }
}
