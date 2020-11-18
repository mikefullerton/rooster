//
//  Event.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import EventKit

class EventKitEvent: Identifiable, Equatable, ObservableObject, CustomStringConvertible {
    @Published private(set) var EKEvent: EKEvent
    @Published var isSubscribed: Bool
    @Published var hasFired: Bool
    @Published var isFiring: Bool
    @Published private(set) var startDate: Date
    @Published private(set) var endDate: Date
    @Published var alarmSound: AlarmSound?
    @Published var title: String
    @Published var id: String
    
    init(withEvent EKEvent: EKEvent,
         subscribed: Bool,
         isFiring: Bool = false,
         hasFired: Bool = false) {
        self.EKEvent = EKEvent
        self.isSubscribed = subscribed
        self.hasFired = hasFired
        self.isFiring = isFiring
        self.startDate = EKEvent.startDate
        self.endDate = EKEvent.endDate
        self.title = EKEvent.title
        self.id = EKEvent.eventIdentifier
    }
    
    var isInProgress: Bool {
        let now = Date()
        
        let compareToEnd = self.endDate.compare(now)
        if compareToEnd == .orderedAscending {
            return false;
        }

        let compareToStart = self.startDate.compare(now)
        if compareToStart == .orderedAscending {
            return true
        }
        
        return false
    }
    
    func setHasFired() {
        self.hasFired = true
        self.isFiring = false;
    }
    
    func setIsFiring(_ isFiring: Bool) {
        self.isFiring = isFiring
    }
    
    static func == (lhs: EventKitEvent, rhs: EventKitEvent) -> Bool {
        return lhs.id == rhs.id
    }
    
    var description: String {
        return ("Event: title: \(self.title), startTime: \(self.startDate), endTime: \(self.endDate), isFiring: \(self.isFiring), hasFired: \(self.hasFired)")
    }
}
