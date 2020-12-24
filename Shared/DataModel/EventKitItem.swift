//
//  EventKitItem.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation

protocol EventKitItem: Alarmable, Hashable {
    associatedtype ItemType
    func itemWithUpdatedAlarm(_ alarm: EventKitAlarm) -> ItemType
}

