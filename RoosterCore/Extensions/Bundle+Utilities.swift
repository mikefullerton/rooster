//
//  Bundle+Utilities.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 3/5/21.
//

import Foundation

extension Bundle {
    public static var shortVersionString: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
