//
//  KeyViewProviding.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 3/10/21.
//

import Cocoa
import Foundation

public protocol KeyViewProviding {
    var initialKeyViewForWindow: NSView? { get }
}
