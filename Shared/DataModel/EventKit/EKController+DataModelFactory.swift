//
//  EKController+DataModelFactory.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/20/20.
//

import Foundation
import EventKit

/// interface used by EKController to fetch all the data and create a new updated DataModel
extension EKController {
    
    private func handleBothEKDataModelsFetched(calendarDataModel: EKDataModel,
                                               delegateCalendarModel: EKDataModel,
                                               previousDataModel: DataModel,
                                               completion: @escaping (_ dataModel: DataModel)-> Void) {

        let factory = DataModelFactory(personalCalendarModel: calendarDataModel,
                                               delegateCalendarModel: delegateCalendarModel,
                                               previousDataModel: previousDataModel,
                                               dataModelStorage: self.dataModelStorage)

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
                    self.logger.log("found duplicate calendar: \(delegateCalendar), \(delegateCalendar.uniqueID)")
                }
            }
            
            if !found {
                outDelegateCalendars.append(delegateCalendar)
            }
            
        }
        
        return outDelegateCalendars
    }

    /// called by EKController
    func fetchNewDataModel(forUserStore userEventStore: EKEventStore,
                           delegateEventStore: EKEventStore?,
                           previousDataModel: DataModel,
                           completion: @escaping (_ dataModel: DataModel)-> Void) {
        
        let storeHelper = EKDataModelFactory(store: userEventStore, dataModelStorage: self.dataModelStorage)
        let calendars = storeHelper.fetchCalendars()
        
        let delegateStoreHelper = EKDataModelFactory(store: delegateEventStore, dataModelStorage: self.dataModelStorage)
        let delegateCalendars = self.removeDuplicateDelegateCalendars(calendars: calendars,
                                                                      delegateCalendars: delegateStoreHelper.fetchCalendars())
        
        var ekCalendarDataModel: EKDataModel? = nil
        var ekDelegateDataModel: EKDataModel? = nil
        
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

        delegateStoreHelper.fetchDataModel(withCalendars: delegateCalendars) { (ekDataModel) in
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
