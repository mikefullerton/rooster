//
//  Event.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import EventKit

class Event: Identifiable, Equatable, ObservableObject, CustomStringConvertible {
    @Published private(set) var EKEvent: EKEvent
    @Published var isSubscribed: Bool
    @Published var hasFired: Bool
    @Published var isFiring: Bool
    @Published private(set) var startDate: Date
    @Published private(set) var endDate: Date
    
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
    }
    
    var id: String {
        return self.EKEvent.eventIdentifier
    }

    var title: String {
        return self.EKEvent.title
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
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.id == rhs.id
    }
    
    var description: String {
        return ("title: \(self.title), startTime: \(self.startDate), endTime: \(self.endDate), isFiring: \(self.isFiring), hasFired: \(self.hasFired)")
    }
}
