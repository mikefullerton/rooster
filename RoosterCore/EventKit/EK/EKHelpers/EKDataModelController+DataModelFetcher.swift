//
//  EKControllerDataModelFetcher.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/29/21.
//

import EventKit
import Foundation

extension EKDataModelController {
    public class DataModelFetcher: Loggable {
        private weak var controller: EKDataModelController?
        private let schedulingQueue: DispatchQueue

        public init(withController controller: EKDataModelController,
                    schedulingQueue: DispatchQueue) {
            self.controller = controller
            self.schedulingQueue = schedulingQueue
        }

        private func removeDuplicateDelegateCalendars(calendars: [EKCalendar],
                                                      delegateCalendars: [EKCalendar]) -> [EKCalendar] {
            var outDelegateCalendars: [EKCalendar] = []

            for delegateCalendar in delegateCalendars {
                var found = false
                calendars.forEach { calendar in
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

        func fetch(withRules rules: EKDataModelControllerRules, completion: @escaping (_ dataModel: EKDataModel) -> Void) {
            guard let controller = self.controller else {
                self.logger.error("controller is nil")
                return
            }

            // swiftlint:disable closure_body_length

            self.schedulingQueue.async { [weak self] in
                guard let self = self else { return }

                var calendarDataModel = EKEventStoreDataModel()
                var delegateCalendarDataModel = EKEventStoreDataModel()

                let dispatchGroup = DispatchGroup()

                dispatchGroup.enter()
                dispatchGroup.enter()

                let storeHelper = EKDataModelFactory(store: controller.store,
                                                     rules: rules)

                let calendars = storeHelper.fetchCalendars()

                DispatchQueue.concurrent.async {
                    storeHelper.fetchDataModel(withCalendars: calendars) { [weak self] dataModel in
                        guard let self = self else { return }
                        defer { dispatchGroup.leave() }

                        calendarDataModel = dataModel
                        self.logger.log("received delegate calendar ekDataModel")
                    }
                }

                DispatchQueue.concurrent.async { [weak self] in
                    guard let self = self else { return }
                    defer { dispatchGroup.leave() }

                    if let delegateEventStore = controller.delegateEventStore {
                        let delegateEventStoreFactory = EKDataModelFactory(store: delegateEventStore,
                                                                           rules: rules)

                        let delegateCalendars = delegateEventStoreFactory.fetchCalendars()

                        let deDupedDelegateCalendars = self.removeDuplicateDelegateCalendars(calendars: calendars,
                                                                                             delegateCalendars: delegateCalendars)
                        dispatchGroup.enter()
                        delegateEventStoreFactory.fetchDataModel(withCalendars: deDupedDelegateCalendars) { [weak self] dataModel in
                            guard let self = self else { return }
                            defer { dispatchGroup.leave() }
                            self.logger.log("received delegate calendar ekDataModel")
                            delegateCalendarDataModel = dataModel
                        }
                    }
                }

                dispatchGroup.wait()

                let dataModel = EKDataModel(calendarStoreDataModel: calendarDataModel,
                                            delegateCalendarEventStoreDataModel: delegateCalendarDataModel)

                self.logger.log("Loaded ekDataModel: \(dataModel.description)")

                completion(dataModel)
            }
        }
    }
}
