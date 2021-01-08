//
//  CalendarItem.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation

protocol CalendarItem: CustomStringConvertible, Loggable {
    var id: String { get }

    var alarm: Alarm { get set }
    var title: String { get }
    var calendar: Calendar { get }
    var location: String? { get }
    var notes: String? { get }
    var url: URL? { get }
    var isSubscribed: Bool { get set }
    
    func isEqualTo(_ item: CalendarItem) -> Bool
}

