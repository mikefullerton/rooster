//
//  Highlightable.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/11/21.
//

import Foundation

public protocol Highlightable {
    var isHighlighted: Bool { get set }
    var isEnabled: Bool { get set }
}
