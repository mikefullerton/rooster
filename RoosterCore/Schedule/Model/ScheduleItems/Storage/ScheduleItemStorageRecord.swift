//
//  ScheduleItemStoredData.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/12/21.
//

import Foundation

public protocol ScheduleItemStorageRecord: AbstractEquatable, CustomStringConvertible {
    var isEnabled: Bool { get set }
    var finishedDate: Date? { get set }
    var startDate: Date? { get set }
    var endDate: Date? { get set }
    var isRecurring: Bool { get set }
    var modificationDate: Date { get }
    var creationDate: Date { get }
}
