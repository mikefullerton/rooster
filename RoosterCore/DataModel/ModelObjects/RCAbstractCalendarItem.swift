//
//  RCAbstractCalendarItem.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/22/21.
//

import Foundation

public protocol RCAbstractCalendarItem: CustomStringConvertible, Loggable {
    
    var typeDisplayName: String { get }
    var title: String { get }
    var id: String { get }
}
