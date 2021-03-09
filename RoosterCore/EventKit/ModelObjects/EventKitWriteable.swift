//
//  EventKitWritable.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/3/21.
//

import Foundation

public protocol EventKitWriteable {
    var hasChanges: Bool { get }

    func saveEventKitObject() throws
}
