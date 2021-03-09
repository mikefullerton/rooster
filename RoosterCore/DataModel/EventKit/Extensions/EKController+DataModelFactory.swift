//
//  EKController+DataModelFactory.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/20/20.
//

import Foundation
import EventKit

/// interface used by EKController to fetch all the data and create a new updated RCCalendarDataModel
extension EKController {
    
    private func handleBothEKDataModelsFetched(calendarDataModel: EKDataModel,
                                               delegateCalendarModel: EKDataModel,
                                               previousDataModel: RCCalendarDataModel,
                                               completion: @escaping (_ dataModel: RCCalendarDataModel)-> Void) {

        let factory = DataModelFactory(personalCalendarModel: calendarDataModel,
                                       delegateCalendarModel: delegateCalendarModel,
                                       previousDataModel: previousDataModel,
                                       dataModelStorage: self.dataModelStorage,
                                       settings: self.settings)

        let dataModel = factory.createDataModel()
        
        DispatchQueue.main.async {
            completion(dataModel)
        }
    }
    
    private func removeDuplicateDelegateCalendars(calendars: [EKCalendar],
                                                  delegateCalendars: [EKCalendar]) -> [EKCalendar] {
        
        var outDelegateCalendars: [EKCalendar] = []
        
        for delegateCalendar in delegateCalendars {
            var found = false
            calendars.forEach { (calendar) in
                if  calendar.uniqueID == delegateCalendar.uniqueID {
                    found = true
                    self.logger.debug("found duplicate calendar: \(delegateCalendar), \(delegateCalendar.uniqueID)")
                }
            }
            
            if !found {
                outDelegateCalendars.append(delegateCalendar)
            }
            
        }
        
        return outDelegateCalendars
    }

    /// called by EKController
    
    func fetchNewDataModel(completion: @escaping (_ dataModel: RCCalendarDataModel) -> Void) {
        self.fetchNewDataModel(forUserStore: self.store,
                               delegateEventStore: self.delegateEventStore,
                               previousDataModel: self.dataModel) { (newDataModel) in
            
            self.logger.log("did receive new dataModel")
            
            completion(newDataModel)
        }
    }
    
    func fetchNewDataModel(forUserStore userEventStore: EKEventStore,
                           delegateEventStore delegateEventStoreOrNil: EKEventStore?,
                           previousDataModel: RCCalendarDataModel,
                           completion: @escaping (_ dataModel: RCCalendarDataModel)-> Void) {
        
        let storeHelper = EKDataModelFactory(store: userEventStore,
                                             settings: self.settings,
                                             dataModelStorage: self.dataModelStorage)
        let calendars = storeHelper.fetchCalendars()
        
        var delegateStoreHelper: EKDataModelFactory?
        var delegateCalendars: [EKCalendar] = []
        
        if let delegateEventStore = delegateEventStoreOrNil {
            delegateStoreHelper = EKDataModelFactory(store: delegateEventStore,
                                                     settings: self.settings,
                                                     dataModelStorage: self.dataModelStorage)
            
            delegateCalendars = self.removeDuplicateDelegateCalendars(calendars: calendars,
                                                                      delegateCalendars: delegateStoreHelper!.fetchCalendars())
        }
            
        var ekCalendarDataModel: EKDataModel?
        var ekDelegateDataModel: EKDataModel?
        
        storeHelper.fetchDataModel(withCalendars: calendars) { (ekDataModel) in
            ekCalendarDataModel = ekDataModel
            
            self.logger.log("received new ekDataModel model for user event store")
            
            if ekDelegateDataModel != nil {
                self.handleBothEKDataModelsFetched(calendarDataModel: ekCalendarDataModel!,
                                                   delegateCalendarModel: ekDelegateDataModel!,
                                                   previousDataModel: previousDataModel,
                                                   completion: completion)
            }
        }

        if let delegateEventStoreFactory = delegateStoreHelper {
            delegateEventStoreFactory.fetchDataModel(withCalendars: delegateCalendars) { (ekDataModel) in
                ekDelegateDataModel = ekDataModel

                self.logger.log("received delegate calendar ekDataModel")

                if ekCalendarDataModel != nil {
                    self.handleBothEKDataModelsFetched(calendarDataModel: ekCalendarDataModel!,
                                                       delegateCalendarModel: ekDelegateDataModel!,
                                                       previousDataModel: previousDataModel,
                                                       completion: completion)
                }
            }
        }
    }
    
}
