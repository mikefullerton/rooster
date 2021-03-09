//
//  ButtonMouseEventSource.swift
//  RoosterCore-macOS
//
//  Created by Mike Fullerton on 4/9/21.
//

import Foundation

public protocol ButtonMouseEventSource: MouseEventSource {
    var title: String { get set }
    var isEnabled: Bool { get set }
}
