//
//  PreferencesView.swift
//  Rooster
//
//  Created by Mike Fullerton on 11/14/20.
//

import SwiftUI


struct CalendarPreferencesView: View {

    @ObservedObject var dataModel: DataModel = DataModel.instance
    
    @State var calendars: SourceToCalendarMap
    @State var delegateCalendars: SourceToCalendarMap
    
//    init(calendars: SourceToCalendarMap,
//         delegateCalendars: SourceToCalendarMap) {
//        self.calendars = calendars
//        self.delegateCalendars = delegateCalendars
//
//        for (source, calendars) in self.calendars {
//            for calendar in calendars {
//                if source == "iCloud" {
//                    print("D: \(source): \(calendar)")
//                }
//            }
//        }
//    }
//
    var body: some View {
        VStack(alignment: .center, spacing: 0) { 
            CalendarListView(calendars: $calendars)
            Text("Delegate Calendars")
            CalendarListView(calendars: $delegateCalendars)
        }
        .onAppear(perform: {
            self.calendars = self.dataModel.calendars
            self.delegateCalendars = self.dataModel.delegateCalendars
        })
        .onReceive(dataModel.objectWillChange, perform: { _ in
            self.calendars = self.dataModel.calendars
            self.delegateCalendars = self.dataModel.delegateCalendars
        })
    }
//
//            Dictionary.replaceAll(inDictionary: &self.calendars,
//                                  withContentsOf: self.dataModel.calendars)
//
//            Dictionary.replaceAll(inDictionary: &self.delegateCalendars,
//                                  withContentsOf: self.dataModel.delegateCalendars)
//
//        })
//        .onReceive(dataModel.objectWillChange, perform: { _ in
//
//            Dictionary.replaceAll(inDictionary: &self.calendars,
//                                  withContentsOf: self.dataModel.calendars)
//
//            Dictionary.replaceAll(inDictionary: &self.delegateCalendars,
//                                  withContentsOf: self.dataModel.delegateCalendars)
//
////            self.calendars.removeAll()
////
////            for (source, _) in self.dataModel.calendars {
////                self.calendars[source] = self.dataModel.calendars[source]
////            }
////
//////            self.calendars.add(contentsOf: self.dataModel.calendars)
////            self.delegateCalendars = self.dataModel.delegateCalendars
//
//            for (source, calendars) in self.dataModel.calendars {
//                for calendar in calendars {
//                    if source == "iCloud" {
//                        for (innerSource, innerCalendars) in self.calendars {
//                            for innerCalendar in innerCalendars {
//                                if innerCalendar.id == calendar.id {
//                                    print("A: \(source): \(calendar)")
//                                    print("B: \(innerSource): \(innerCalendar)")
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//
//
//        })
//    }
}

//struct PreferencesView_Previews: PreviewProvider {
//    static var previews: some View {
//        CalendarPreferencesView()
//    }
//}
