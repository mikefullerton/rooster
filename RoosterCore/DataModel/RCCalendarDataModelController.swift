//
//  RCCalendarDataModelController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation

/// interface the app uses to access or update the data model.
public class RCCalendarDataModelController : EKControllerDelegate, Loggable {
    
    public static let DidChangeEvent = Notification.Name("DataModelDidChangeEvent")
    

    private var disableSaving: Bool = false
    
    // public properties
    private(set) public var dataModel: RCCalendarDataModel? {
        didSet {
            if oldValue != nil {
                if oldValue != self.dataModel {
                    self.saveDataModel()
                } else {
                    self.logger.log("no change in data model")
                }
            }
            else if self.dataModel != nil {
                self.notify()
            }
        }
    }

    private(set) public var isAuthenticating : Bool
    private(set) public var isAuthenticated: Bool

    // private stuff
    private let eventKitController: EKController
    private var needsNotify = false
    
    public var dataModelStorage: DataModelStorage {
        return self.eventKitController.dataModelStorage
    }
    
    public init(withEventKitController eventKitController: EKController) {
        self.eventKitController = eventKitController
        self.isAuthenticating = false
        self.isAuthenticated = false
        self.eventKitController.delegate = self
    }
    
    public var allItems: [RCCalendarItem] {
        return self.dataModel?.allItems ?? []
    }

    public var events: [RCEvent] {
        return self.dataModel?.events ?? []
    }

    public var reminders: [RCReminder] {
        return self.dataModel?.reminders ?? []
    }
    
    public var calendars: [CalendarSource: [RCCalendar]] {
        return self.dataModel?.calendars ?? [:]
    }

    public var delegateCalendars: [CalendarSource: [RCCalendar]] {
        return self.dataModel?.delegateCalendars ?? [:]
    }

    // MARK: Methods
    
    private func saveDataModel() {
        self.logger.log("Saving data model")
        if let dataModel = self.dataModel {
            self.dataModelStorage.writeDateModel(dataModel) { success, error in
                
                // TODO: handle failure
                
                self.notify()
                self.reloadData()
            }
        }
    }
    
    public func readFromStorage(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        self.dataModelStorage.read(completion: completion)
    }
    
    public func reloadData() {
        self.eventKitController.reloadDataModel()
    }
    
    public func update(calendar newCalendar: RCCalendar) {
        
        var newCalendarLookup: [CalendarID: RCCalendar] = [:]
        
        if let dataModel = self.dataModel {
        
            let newCalendarList = self.newCalendars(for: newCalendar,
                                                    calendarMap: dataModel.calendars,
                                                    newCalendarLookup: &newCalendarLookup)

            let newDelegateCalendarList = self.newCalendars(for: newCalendar,
                                                            calendarMap: dataModel.delegateCalendars,
                                                            newCalendarLookup: &newCalendarLookup)
            
            if newCalendarList != nil || newDelegateCalendarList != nil {
                
                let updatedCalendarList = newCalendarList == nil ? dataModel.calendars : newCalendarList!
                let updatedDelegateList = newDelegateCalendarList == nil ? dataModel.delegateCalendars : newDelegateCalendarList!
                
                self.dataModel = RCCalendarDataModel(calendars: updatedCalendarList,
                                                     delegateCalendars: updatedDelegateList,
                                                     events: dataModel.events,
                                                     reminders: dataModel.reminders)
                
                self.logger.log("RCCalendarDataModel: updated calendar: \(newCalendar.sourceTitle): \(newCalendar.title)")
            }
        }
            
    }

    public func update(event: RCEvent) {
        self.update(someEvents: [event])
    }
    
    public func update(someEvents: [RCEvent]) {

        if let dataModel = self.dataModel,
            let updatedEvents = self.merge(someItems: someEvents,
                                           inItems: dataModel.events) {
            
            self.dataModel = RCCalendarDataModel(calendars: dataModel.calendars,
                                                  delegateCalendars: dataModel.delegateCalendars,
                                                  events: updatedEvents,
                                                  reminders: dataModel.reminders)
        }
    }
    
    public func update(reminder: RCReminder) {
        self.update(someReminders: [reminder] )
    }
    
    public func update(someReminders: [RCReminder]) {
        if  let dataModel = self.dataModel,
            let updatedReminders = self.merge(someItems: someReminders,
                                              inItems: dataModel.reminders) {
        
            self.dataModel = RCCalendarDataModel(calendars: dataModel.calendars,
                                                 delegateCalendars: dataModel.delegateCalendars,
                                                 events: dataModel.events,
                                                 reminders: updatedReminders)
        }
    }
    
    public func update(calendarItem: RCCalendarItem) {
        if let event = calendarItem as? RCEvent {
            self.update(event: event)
        } else if let reminder = calendarItem as? RCReminder {
            self.update(reminder: reminder)
        }
    }
    
    public func requestAccessToCalendars(_ completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        self.isAuthenticating = true
        self.eventKitController.requestAccess { (success, error) in
            DispatchQueue.main.async {
                self.isAuthenticating = false
                if success {
                    self.isAuthenticated = true
                }
                
                completion(success, error)
            }
        }
    }
    
    // MARK: private implementation
    
    private func merge<T>(someItems: [T], inItems: [T]) -> [T]? where T: RCCalendarItem, T: Equatable {
        
        var newItemList: [T] = []

        var foundDifferentItem = false
        
        for item in inItems {
            
            var didAdd = false
            someItems.forEach { (someItem) in
                if someItem.id == item.id {
                    
                    if someItem == item {
                        self.logger.log("event not changed, ignoring update: \(someItem)")
                    } else {
                        foundDifferentItem = true
                        newItemList.append(someItem)
                        didAdd = true
                        self.logger.log("updated event: \(someItem)")
                    }
                }
            }
            
            if !didAdd {
                newItemList.append(item)
            }
        }

        if foundDifferentItem {
            return newItemList
        }
        
        return nil
    }
    
    private func newCalendars(for newCalendar: RCCalendar,
                              calendarMap: [CalendarSource: [RCCalendar]],
                              newCalendarLookup: inout [CalendarID: RCCalendar] ) -> [CalendarSource: [RCCalendar]]? {
        
        var newCalendarMap: [CalendarSource: [RCCalendar]] = [:]
        
        var foundChange = false
        for (source, calendars) in calendarMap {
            var newCalendarList: [RCCalendar] = []
            
            for calendar in calendars {
                if calendar.id == newCalendar.id {
                    if calendar != newCalendar {
                        foundChange = true
                        newCalendarList.append(newCalendar)
                        newCalendarLookup[source] = newCalendar
                        self.logger.log("Calendar \(calendar.sourceTitle):\(calendar.title) changed, updating")
                        
                    } else {
                        self.logger.log("Calendar \(calendar.sourceTitle):\(calendar.title) unchanged, ignoring update")
                        newCalendarList.append(calendar)
                        newCalendarLookup[source] = calendar
                    }
                } else {
                    newCalendarList.append(calendar)
                    newCalendarLookup[source] = calendar
                }
            }
            
            newCalendarMap[source] = newCalendarList
        }
        
        return foundChange ? newCalendarMap : nil
    }
    
    private func notify() {
        self.needsNotify = true
    
        DispatchQueue.main.async {
            if self.needsNotify {
                self.needsNotify = false
                self.logger.log("EventDataModel did change notification sent")
                NotificationCenter.default.post(name: RCCalendarDataModelController.DidChangeEvent, object: self)
            }
        }
    }
    
    // MARK: EKController delegate method
    
    public func eventKitController(_ controller: EKController,
                                   didReloadDataModel dataModel: RCCalendarDataModel) {
     
        self.dataModel = dataModel
    }
    
    // MARK: Alarms
    public func enableAllPersonalCalendars() {
        if let dataModel = self.dataModel {
            var newCalendars: [CalendarSource: [RCCalendar]] = [:]
            
            for (source, calendars) in dataModel.calendars {
                
                newCalendars[source] = calendars.map {
                    var calendar = $0
                    calendar.isSubscribed = true
                    
                    return calendar
                }
                
            }
        
            self.logger.log("Enabled default calendars")
            
            self.dataModel = RCCalendarDataModel(calendars: newCalendars,
                                                 delegateCalendars: dataModel.delegateCalendars,
                                                 events: dataModel.events,
                                                 reminders: dataModel.reminders)
        }
    }

}

extension RCCalendar {
    public func set(subscribed: Bool) {
        var updatedCalendar = self
        updatedCalendar.isSubscribed = subscribed
        Controllers.dataModel.update(calendar: updatedCalendar)
    }
}

extension RCCalendarDataModelController {
    
    public func nextAlarmDate(forItems items: [RCCalendarItem]) -> Date? {
        var nextDate:Date?
        
        for item in items {
            let alarm = item.alarm
            
            if alarm.willFire &&
                (nextDate == nil || alarm.startDate?.isBeforeDate(nextDate!) ?? false) {
                nextDate = alarm.startDate
            }
        }

        return nextDate
    }
    
    public var nextAlarmDate: Date? {
        return self.nextAlarmDate(forItems: self.allItems)
    }
}

extension RCCalendarDataModelController {
    
    public struct SchedulingGap: CustomStringConvertible {
        public let startDate: Date
        public let endDate: Date
        public let length: TimeInterval
        
        init?(startDate: Date, endDate: Date) {
            
            let length = endDate.difference(fromDate: startDate)
            
            guard length > 0.0 else {
                return nil
            }
            
            self.length = length
            self.startDate = startDate
            self.endDate = endDate
        }
        
        public var description: String {
            return """
            type(of: self): \
            startDate: \(self.startDate.shortDateAndLongTimeString), \
            endDate: \(self.endDate.shortDateAndLongTimeString), \
            length: \(DigitalClockTimeDisplayFormatter.formattedInterval(self.length))
            """
        }
    }
    
    public enum GapAlignment {
        case hour
        case halfHour
        case quarterHour
        
        
        public static func alignment(withInterval interval: TimeInterval) -> GapAlignment {
            
            let minutes = Date.minutes(fromInterval: interval)
            
            if minutes > 30 {
                return .hour
            }
            
            if minutes > 15 {
                return .halfHour
            }
            
            return .quarterHour
        }
        
    }
    
    public func schedulingGaps(withStartTime earliestStartTime: Date,
                               gapAlignment: GapAlignment,
                               excludingItems excludedItems:[RCCalendarItem] = []) -> [SchedulingGap] {
        
        var gaps:[SchedulingGap] = []
        
        var lastItemEndDate = earliestStartTime
        
        for item in self.allItems {
            
            if excludedItems.contains(where: { $0.id == item.id } ) {
                continue
            }
            
            if let startDate = item.alarm.startDate,
                let endDate = item.alarm.endDate,
                startDate.isAfterDate(lastItemEndDate) {
            
                if let gap = SchedulingGap(startDate:lastItemEndDate, endDate:startDate) {
                    gaps.append(gap)
                }
                
                lastItemEndDate = endDate
            }
        }
        
        return gaps
    }
    
    public func findEmptyTimeSlot(withEarliestTime earliestTime: Date,
                                  withLength slotLength: TimeInterval,
                                  withinRange range: ClosedRange<Int>) -> SchedulingGap? {

        let minTime = earliestTime.removeMinutesAndSeconds.addHours(range.lowerBound)
        let maxTime = minTime.addHours(range.upperBound)
        
        let alignment = GapAlignment.alignment(withInterval:slotLength)
    
        let allGaps = self.schedulingGaps(withStartTime: minTime,
                                          gapAlignment: alignment,
                                          excludingItems: [])
        
        for gap in allGaps {
            if gap.startDate.isEqualToOrBeforeDate(maxTime) && gap.length >= slotLength {
                return gap
            }
        }
        
        return nil
    }
    
    
    public func findEmptyTimeSlot(forCalendarItem calendarItem: RCCalendarItem,
                                  withinRange range: ClosedRange<Int>) -> SchedulingGap? {
        
        if let startTime = calendarItem.alarm.startDate  {
            return self.findEmptyTimeSlot(withEarliestTime:Date.later(Date(), startTime),
                                          withLength:calendarItem.length,
                                          withinRange:range)
        }
        
        return nil
    }
    
}
