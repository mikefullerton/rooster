//
//  ScheduleController+TimeSlot.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/3/21.
//

import Foundation

extension ScheduleController {
    // swiftlint:disable todo
    // TODO: search future days for slots
    // swiftlint:enable todo

    public func findEmptyTimeSlot(withinRange boundingRange: DateRange,
                                  slotLengthInMinutes lengthInMinutes: Int,
                                  completion: @escaping (_ success: Bool, _ timeSlot: DateRange?) -> Void) {
        if let slot = self.schedule.findEmptyTimeSlot(withinRange: boundingRange, slotLengthInMinutes: lengthInMinutes) {
            completion(true, slot)
        } else {
            completion(false, nil)
        }
    }

    public func findEmptyTimeSlot(forScheduleItem scheduleItem: ScheduleItem,
                                  withinRange boundingRange: DateRange,
                                  completion: @escaping (_ success: Bool, _ timeSlot: DateRange?) -> Void) {
        if let slot = self.schedule.findEmptyTimeSlot(forScheduleItem: scheduleItem,
                                                      withinRange: boundingRange) {
            completion(true, slot)
        } else {
            completion(false, nil)
        }
    }
}
