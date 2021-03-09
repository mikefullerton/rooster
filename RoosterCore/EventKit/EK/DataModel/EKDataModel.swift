//
//  EKDataModel.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/31/21.
//

import EventKit
import Foundation

public struct EKDataModel: Equatable, CustomStringConvertible {
    public let calendarStoreDataModel: EKEventStoreDataModel
    public let delegateCalendarEventStoreDataModel: EKEventStoreDataModel

    public init(calendarStoreDataModel: EKEventStoreDataModel,
                delegateCalendarEventStoreDataModel: EKEventStoreDataModel) {
        self.calendarStoreDataModel = calendarStoreDataModel
        self.delegateCalendarEventStoreDataModel = delegateCalendarEventStoreDataModel
    }

    public init() {
        self.init(calendarStoreDataModel: EKEventStoreDataModel(),
                  delegateCalendarEventStoreDataModel: EKEventStoreDataModel())
    }

    public var description: String {
        """
        \(type(of: self)): \
        calendarStoreDataModel: \(self.calendarStoreDataModel.description), \
        delegateCalendarStoreDataModel: \(self.delegateCalendarEventStoreDataModel.description)
        """
    }
}
