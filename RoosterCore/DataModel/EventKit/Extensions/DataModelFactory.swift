//
//  EKController+IntermediateModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/3/20.
//

import Foundation
import EventKit

/// This takes the two IntermediateDataModel structs and combines them into the Single and final RCCalendarDataModel
struct DataModelFactory {

    private let personalCalendarModel: IntermediateDataModel
    private let delegateCalendarModel: IntermediateDataModel
    
    private(set) var events: [RCEvent]
    private(set) var reminders: [RCReminder]
    private(set) var personalCalendars: [CalendarSource: [RCCalendar]]
    private(set) var delegateCalendars: [CalendarSource: [RCCalendar]]
    
    let dataModelStorage: DataModelStorage
    let settings: EKDataModelSettings
    
    init(personalCalendarModel: EKDataModel,
         delegateCalendarModel: EKDataModel,
         previousDataModel: RCCalendarDataModel,
         dataModelStorage: DataModelStorage,
         settings: EKDataModelSettings) {
        
        self.dataModelStorage = dataModelStorage
        self.settings = settings
        
        let personalCalendarModel = IntermediateDataModel(model: personalCalendarModel, dataModelStorage: dataModelStorage, settings: settings)
        let delegateCalendarModel = IntermediateDataModel(model: delegateCalendarModel, dataModelStorage: dataModelStorage, settings: settings)
        
        self.personalCalendarModel = personalCalendarModel
        self.delegateCalendarModel = delegateCalendarModel
        
        self.personalCalendars = personalCalendarModel.groupedCalendars
        self.delegateCalendars = delegateCalendarModel.groupedCalendars

        self.events = personalCalendarModel.events + delegateCalendarModel.events

        self.reminders = personalCalendarModel.reminders + delegateCalendarModel.reminders
    }
    
    private func calendar(forIdentifier identifier: String) -> RCCalendar? {
     
        if let calendar = self.personalCalendarModel.calendar(forIdentifier: identifier) {
            return calendar
        }
        
        if let calendar = self.delegateCalendarModel.calendar(forIdentifier: identifier) {
            return calendar
        }

        return nil
    }
    
    /// actually create the final data model
    func createDataModel() -> RCCalendarDataModel {
        return RCCalendarDataModel(calendars: self.personalCalendars,
                         delegateCalendars: self.delegateCalendars,
                         events: self.events,
                         reminders: self.reminders)
    }
    
}

