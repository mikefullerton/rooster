//
//  CalendarGroup.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/18/20.
//

import Foundation

class CalendarGroup: Identifiable, ObservableObject, CustomStringConvertible, Equatable  {
    
    @Published var calendars: [EventKitCalendar] = []
    @Published var groupName: String
    
    init(withGroupName groupName: String,
         calendars: [EventKitCalendar]) {
        self.groupName = groupName
        self.calendars = calendars
    }
    
    static func == (lhs: CalendarGroup, rhs: CalendarGroup) -> Bool {
        return lhs === rhs
    }
    
    var description: String {
        return ""
    }
}
