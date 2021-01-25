//
//  CalendarItem.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation

protocol CalendarItemBehavior {
    func stopAlarmButtonClicked()
    var timeLabelDisplayString: String { get }
}

protocol CalendarItem: CustomStringConvertible, Loggable, CalendarItemBehavior {
    var id: String { get }

    var externalIdentifier: String { get }
    
    var alarm: Alarm { get set }
    var title: String { get }
    var calendar: Calendar { get }
    var location: String? { get }
    var notes: String? { get }
    var url: URL? { get }
    var isSubscribed: Bool { get set }
    
    func isEqualTo(_ item: CalendarItem) -> Bool
    
    
}

