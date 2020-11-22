//
//  SwiftUIView.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import SwiftUI


struct CalendarListView: View {
    @ObservedObject var dataModel: DataModel = DataModel.instance
    
    @Binding var calendars: SourceToCalandarMap
    
//    init(calendars: SourceToCalandarMap) {
//        self.calendars = calendars
//
//        for (source, calendars) in self.calendars {
//            for calendar in calendars {
//                if source == "iCloud" {
//                    print("C: \(source): \(calendar)")
//                }
//            }
//        }
//
//        print("WTF")
//    }
    
    var body: some View {
        List {
            ForEach(calendars.sortedKeys, id: \.self) { sourceName in
                if let calendars = calendars[sourceName] {
                    Section(header: Text(sourceName)) {
                        ForEach(calendars, id: \.id) { calendar in
                            CheckBox2(title: calendar.title,
                                      isOn: calendar.isSubscribed) { (isOn) in
                                calendar.set(subscribed: isOn)
                            }
                        }
                    }
                }
            }
        }
        .onAppear(perform: {
            self.calendars = self.dataModel.calendars
//            self.delegateCalendars = self.dataModel.delegateCalendars
        })
        .onReceive(dataModel.objectWillChange, perform: { _ in
            self.calendars = self.dataModel.calendars
//            self.delegateCalendars = self.dataModel.delegateCalendars
        })

    }
    
}


//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
//}
