//
//  PreferencesView.swift
//  Rooster
//
//  Created by Mike Fullerton on 11/14/20.
//

import SwiftUI


struct PreferencesView: View, Reloadable {

    @State private var calendars: [String: [EventKitCalendar]] = AppController.instance.calendars
    @EnvironmentObject private var calendarData: CalendarData

    private var reloader: AuthenticationReloader?

    init() {
        self.reloader = AuthenticationReloader(for: self)
    }

    var sortedGroupNames: [String] {
        let names:[String] = Array(self.calendars.keys)
        let sortedNames = names.sorted {
                $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending
        }
        return sortedNames
    }
    
    var body: some View {
        Text("Calendars")
        let groupNames = self.sortedGroupNames
        List {
            ForEach(groupNames, id: \.self) { groupName in
                if let calendars = self.calendars[groupName] {
                    Section(header: Text(groupName)) {
                        let sortedList = calendars.sorted {
                            $0.title.localizedCaseInsensitiveCompare($1.title) == ComparisonResult.orderedAscending
                        }
                        ForEach(sortedList, id: \.id) { calendar in
                            PreferenceRow(calendar: calendar)
                        }
                    }
                }
            }
        }
        .onAppear(perform: {
            self.calendars = AppController.instance.calendars
        })
        .onReceive(calendarData.objectWillChange, perform: { _ in
            self.calendars = AppController.instance.calendars

        })
    }

    func reload() {
        self.calendars = AppController.instance.calendars
        print("got reload: \(self.calendars), \(AppController.instance.calendars)")
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
