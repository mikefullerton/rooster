//
//  EventKitController+EventKitDataModelFactory.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/20/20.
//

import Foundation
import EventKit

/// interface used by EventKitController to fetch all the data and create a new updated EventKitDataModel
extension EventKitController {
    
    private func handleBothEKDataModelsFetched(calendarDataModel: EKDataModel,
                                               delegateCalendarModel: EKDataModel,
                                               previousDataModel: EventKitDataModel,
                                               completion: @escaping (_ dataModel: EventKitDataModel)-> Void) {

        let factory = EventKitDataModelFactory(personalCalendarModel: calendarDataModel,
                                               delegateCalendarModel: delegateCalendarModel,
                                               previousDataModel: previousDataModel)

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

    /// called by EventKitController
    func fetchNewDataModel(forUserStore userEventStore: EKEventStore,
                           delegateEventStore: EKEventStore?,
                           previousDataModel: EventKitDataModel,
                           completion: @escaping (_ dataModel: EventKitDataModel)-> Void) {
        
        let storeHelper = EKDataModelFactory(store: userEventStore)
        let calendars = storeHelper.fetchCalendars()
        
        let delegateStoreHelper = EKDataModelFactory(store: delegateEventStore)
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
