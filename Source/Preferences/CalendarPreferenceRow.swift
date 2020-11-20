//
//  PreferencesRow.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/16/20.
//

import SwiftUI

struct CalendarPreferenceRow: View {
    @State var calendar: EventKitCalendar
    @State var isSubscribed: Bool = false
        
    func toggle() {
        self.isSubscribed = !self.isSubscribed
        self.calendar.set(subscribed: self.isSubscribed)
    }
    
    var body: some View {
        Button(action: {
            self.toggle()
        }, label: {
            HStack {
                Image(systemName: self.isSubscribed ? "checkmark.square" : "square")
                Text(calendar.title)
            }
        })
        .onAppear(perform: {
            self.isSubscribed = self.calendar.isSubscribed
        })
    }
}

//struct PreferencesRow_Previews: PreviewProvider {
//    static var previews: some View {
//
//        ForEach(testCalendars, id: \.id) { calendar in
//            PreferenceRow(calendar: calendar)
//        }
//    }
//}
