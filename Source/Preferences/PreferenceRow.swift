//
//  PreferencesRow.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/16/20.
//

import SwiftUI

struct PreferenceRow: View {
    @ObservedObject var calendar: EventKitCalendar
    @State var isChecked: Bool = false
    
    func toggle() {
        self.calendar.isSubscribed = !self.calendar.isSubscribed
        self.isChecked = !isChecked
    }
    
    var body: some View {
        Button(action: {
            self.toggle()
        }, label: {
            HStack {
                Image(systemName: self.isChecked ? "checkmark.square" : "square")
                Text(calendar.title)
            }
        })
        
        .onAppear(perform: {
            self.isChecked = self.calendar.isSubscribed
        })
        
//        Text("\(calendar.sourceTitle): \(calendar.title)")
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
