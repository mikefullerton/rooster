//
//  PreferencesView.swift
//  Rooster
//
//  Created by Mike Fullerton on 11/14/20.
//

import SwiftUI


struct CalendarPreferencesView: View {

    @State private var calendars: [String: [EventKitCalendar]] = AppController.instance.calendarData.calendars
    @State private var delegateCalendars: [String: [EventKitCalendar]] = AppController.instance.calendarData.delegateCalendars
    @EnvironmentObject private var calendarData: CalendarData

    var sortedGroupNames: [String] {
        let names:[String] = Array(self.calendars.keys)
        let sortedNames = names.sorted {
                $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending
        }
        return sortedNames
    }
    
    var sortedDelegateGroupNames: [String] {
        let names:[String] = Array(self.delegateCalendars.keys)
        let sortedNames = names.sorted {
                $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending
        }
        return sortedNames
    }
    
    var body: some View {
        let groupNames = self.sortedGroupNames
        let delegateGroupNames = self.sortedDelegateGroupNames
        VStack(alignment: .center, spacing: 0) {
            List {
                ForEach(groupNames, id: \.self) { groupName in
                    if let calendars = self.calendars[groupName] {
                        Section(header: Text(groupName)) {
                            let sortedList = calendars.sorted {
                                $0.title.localizedCaseInsensitiveCompare($1.title) == ComparisonResult.orderedAscending
                            }
                            ForEach(sortedList, id: \.id) { calendar in
                                CalendarPreferenceRow(calendar: calendar)
                            }
                        }
                    }
                }
            }
            Text("Delegate Calendars")
            List {
                ForEach(delegateGroupNames, id: \.self) { delegateGroupName in
                    if let delegateCalendars = self.delegateCalendars[delegateGroupName] {
                        Section(header: Text(delegateGroupName)) {
                            let sortedList = delegateCalendars.sorted {
                                $0.title.localizedCaseInsensitiveCompare($1.title) == ComparisonResult.orderedAscending
                            }
                            ForEach(sortedList, id: \.id) { delegateCalendars in
                                CalendarPreferenceRow(calendar: delegateCalendars)
                            }
                        }
                    }
                }
            }
        }
        .onAppear(perform: {
            self.calendars = AppController.instance.calendarData.calendars
            self.delegateCalendars = AppController.instance.calendarData.delegateCalendars
        })
        .onReceive(calendarData.objectWillChange, perform: { _ in
            self.calendars = AppController.instance.calendarData.calendars
            self.delegateCalendars = AppController.instance.calendarData.delegateCalendars
        })
    }
}

//struct PreferencesView_Previews: PreviewProvider {
//    static var previews: some View {
//        CalendarPreferencesView()
//    }
//}
