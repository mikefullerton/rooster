//
//  RCDemoEvent.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/9/21.
//

import Foundation

public struct RCDemoEvent: Identifiable, Hashable, EventKitCalendarItem {
    public typealias ID = String

    public var id: String

    public var externalIdentifier: String

    public var alarm: ScheduleItemAlarm

    public var title: String

    public var calendar: EventKitCalendar

    public var location: String?

    public var notes: String?

    public var url: URL?

    public var isSubscribed: Bool

//    public func isEqualTo(_ item: EventKitCalendarItem) -> Bool {
//        return self.id == item.id
//    }
//    
    public var startDate: Date

    public var endDate: Date

    public var description: String {
        "demo"
    }

    public func stopAlarmButtonClicked() {
    }

    public var timeLabelDisplayString: String {
        ""
    }

    init(withID id: String,
         alarm: ScheduleItemAlarm,
         title: String,
         calendar: RCDemoCalendar,
         startDate: Date,
         endDate: Date,
         location: String) {
        self.id = id
        self.externalIdentifier = "external " + id
        self.alarm = alarm
        self.title = title
        self.calendar = calendar
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.notes = nil
        self.isSubscribed = true
    }

    public static func == (lhs: RCDemoEvent, rhs: RCDemoEvent) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
