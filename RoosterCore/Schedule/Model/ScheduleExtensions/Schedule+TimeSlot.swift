//
//  Schedule+TimeSlot.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/27/21.
//

import Foundation

extension Schedule {
    public enum GapAlignment {
        case hour
        case halfHour
        case quarterHour

        public static func alignment(withMinutes minutes: Int) -> GapAlignment {
            if minutes > 30 {
                return .hour
            }

            if minutes > 15 {
                return .halfHour
            }

            return .quarterHour
        }
    }

    public func schedulingGaps(withinRange boundingRange: DateRange,
                               gapAlignment: GapAlignment,
                               excludingItems excludedItems: [ScheduleItem] = []) -> [DateRange] {
        var gaps: [DateRange] = []

        var lastItemEndDate = boundingRange.startDate

        for item in self.items {
            if excludedItems.contains(where: { $0.scheduleItemID == item.scheduleItemID }) {
                continue
            }

            if item.isAllDay {
                continue
            }

            if let dateRange = item.dateRange {
                if dateRange.isAllDay {
                    continue
                }

                if dateRange.endDate.isBeforeDate(boundingRange.startDate) {
                    continue
                }

                if dateRange.startDate.isAfterDate(boundingRange.endDate) {
                    break
                }

                if dateRange.startDate.isAfterDate(lastItemEndDate) {
                    let gap = DateRange(startDate: lastItemEndDate, endDate: dateRange.startDate)
                    gaps.append(gap)
                }
                lastItemEndDate = dateRange.endDate
            }
        }

        if lastItemEndDate.isBeforeDate(boundingRange.endDate) {
            gaps.append(DateRange(startDate: lastItemEndDate, endDate: boundingRange.endDate))
        }

        return gaps
    }

    public func findEmptyTimeSlot(withinRange boundingRange: DateRange,
                                  slotLengthInMinutes lengthInMinutes: Int) -> DateRange? {
        let alignment = GapAlignment.alignment(withMinutes: lengthInMinutes)

        let allGaps = self.schedulingGaps(withinRange: boundingRange,
                                          gapAlignment: alignment,
                                          excludingItems: [])

        for gap in allGaps where gap.lengthInMinutes >= lengthInMinutes {
            return DateRange(startDate: gap.startDate, lengthInMinutes: lengthInMinutes)
        }

        return nil
    }

    public func findEmptyTimeSlot(forScheduleItem scheduleItem: ScheduleItem,
                                  withinRange boundingRange: DateRange) -> DateRange? {
        guard let dateRange = scheduleItem.dateRange else {
            return nil
        }

        return self.findEmptyTimeSlot(withinRange: boundingRange,
                                      slotLengthInMinutes: dateRange.lengthInMinutes)
    }
}
