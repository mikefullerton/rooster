//
//  CalendarScheduleItem+StoredData.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/10/21.
//

import Foundation

    // represents the small subset of data we actually store
public struct ScheduleCalendarStorageRecord: Equatable, CustomStringConvertible {
    public var isEnabled: Bool

    public init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }

    public var description: String {
        """
        \(type(of: self)) \
        isEnabled: \(self.isEnabled)
        """
    }

    public static let `default` = ScheduleCalendarStorageRecord(isEnabled: false)
}

extension ScheduleCalendarStorageRecord: Codable {
    private enum CodingKeys: String, CodingKey {
        case isEnabled
    }

    public init(from decoder: Decoder) throws {
        let defaults = Self.default

        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.isEnabled = try values.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? defaults.isEnabled
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.isEnabled, forKey: .isEnabled)
    }

    public static func == (lhs: ScheduleCalendarStorageRecord, rhs: ScheduleCalendarStorageRecord) -> Bool {
        lhs.isEnabled == rhs.isEnabled
    }
}
