//
//  CalendarSource.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/18/21.
//

import Foundation

public protocol CalendarSource: StringIdentifiable, AbstractEquatable, CustomStringConvertible, Loggable {
    var title: String { get }
}
