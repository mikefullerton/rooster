//
//  URL+Utilities.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation

extension URL {
    var fileName: String {
        return self.deletingPathExtension().lastPathComponent
    }
}
