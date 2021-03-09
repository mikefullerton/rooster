//
//  KeyViewProviding.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 3/10/21.
//

import Foundation
import Cocoa

public protocol KeyViewProviding {
    var initialKeyViewForWindow: NSView? { get }
}
