//
//  String+Localized.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation

extension String {
    public var localized: String {
        // swiftlint:disable nslocalizedstring_require_bundle nslocalizedstring_key
        NSLocalizedString(self, comment: "")
    }
}
