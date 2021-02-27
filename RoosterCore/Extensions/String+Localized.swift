//
//  String+Localized.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation

public extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
