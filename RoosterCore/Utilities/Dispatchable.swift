//
//  Dispatchable.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/29/21.
//

import Foundation

public protocol Dispatchable: Loggable, CustomStringConvertible {
    var serialQueue: DispatchQueue { get }
}

extension Dispatchable {
    public static var defaultSerialQueue: DispatchQueue {
        DispatchQueue(label: "rooster.dispatchable.queue")
    }
}
