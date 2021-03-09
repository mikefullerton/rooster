//
//  CalendarScheduleBehavior.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/10/21.
//

import Foundation

public struct CalendarScheduleBehavior: Equatable, CustomStringConvertible {
    public var workdayStart: TimeDescriptor
    public var workdayEnd: TimeDescriptor

    @ConstrainedInt(maxValue: 7, minValue: 1) public var visibleDayCount: Int = 1
    public var workDays: ScheduleCalendar.WorkDays

    public static let `default` = CalendarScheduleBehavior()

    public init(workdayStart: TimeDescriptor,
                workdayEnd: TimeDescriptor,
                visibleDayCount: Int,
                workDays: ScheduleCalendar.WorkDays) {
        self.workdayStart = workdayStart
        self.workdayEnd = workdayEnd
        self.visibleDayCount = visibleDayCount
        self.workDays = workDays
    }

    public init() {
        self.init(workdayStart: TimeDescriptor(hour: 10),
                  workdayEnd: TimeDescriptor(hour: 18),
                  visibleDayCount: 1,
                  workDays: .weekdays)
    }

    public var description: String {
        """
            \(type(of: self)): \
            visibleDayCount: \(visibleDayCount), \
            workdayStart: \(workdayStart.description), \
            workdayEnd: \(workdayStart.description), \
            workDays: \(workDays.description)
            """
    }

    public var workdayDateRange: DateRange {
        DateRange(startDate: self.workdayStart.date,
                  endDate: self.workdayEnd.date)
    }

    public var visibleDateRange: DateRange {
        let endDate = Date.endOfToday.addDays(self.visibleDayCount - 1)
        return DateRange(startDate: Date(), endDate: endDate)
    }
}

extension CalendarScheduleBehavior: Codable {
    private enum CodingKeys: String, CodingKey {
        case workdayStart
        case workdayEnd
        case visibleDayCount
        case workDays
    }

    public init(from decoder: Decoder) throws {
        let defaults = Self.default

        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.workdayStart = try values.decodeIfPresent(TimeDescriptor.self, forKey: .workdayStart) ?? defaults.workdayStart
        self.workdayEnd = try values.decodeIfPresent(TimeDescriptor.self, forKey: .workdayEnd) ?? defaults.workdayEnd
        self.visibleDayCount = try values.decodeIfPresent(Int.self, forKey: .visibleDayCount) ?? defaults.visibleDayCount
        self.workDays = try values.decodeIfPresent(ScheduleCalendar.WorkDays.self, forKey: .workDays) ?? defaults.workDays
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.workdayStart, forKey: .workdayStart)
        try container.encode(self.workdayEnd, forKey: .workdayEnd)
        try container.encode(self.visibleDayCount, forKey: .visibleDayCount)
        try container.encode(self.workDays, forKey: .workDays)
    }
}

extension ScheduleCalendar {
    public struct WorkDays: DescribeableOptionSet {
        public typealias RawValue = Int

        public private(set) var rawValue: Int

        public static var zero                = WorkDays([])
        public static var sunday              = WorkDays(rawValue: 1 << 1)
        public static var monday              = WorkDays(rawValue: 1 << 2)
        public static let tuesday             = WorkDays(rawValue: 1 << 3)
        public static let wednesday           = WorkDays(rawValue: 1 << 4)
        public static let thursday            = WorkDays(rawValue: 1 << 5)
        public static let friday              = WorkDays(rawValue: 1 << 6)
        public static let saturday            = WorkDays(rawValue: 1 << 7)

        public static let weekdays: WorkDays  = [
            .monday,
            .tuesday,
            .wednesday,
            .thursday,
            .friday
        ]

        public static var descriptions: [(Self, String)] = [
            (.sunday, "sunday"),
            (.monday, "monday"),
            (.tuesday, "tuesday"),
            (.wednesday, "wednesday"),
            (.thursday, "thursday"),
            (.friday, "friday"),
            (.saturday, "saturday")
        ]

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}
