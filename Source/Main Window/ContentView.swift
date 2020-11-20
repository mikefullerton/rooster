//
//  ContentView.swift
//  Shared
//
//  Created by Mike Fullerton on 11/13/20.
//

import SwiftUI

//struct ItemsToolbar: ToolbarContent {
//    let add: () -> Void
//    let sort: () -> Void
//
//    var body: some ToolbarContent {
//        ToolbarItem(placement: .primaryAction) {
//            Button("Add", action: add)
//        }
//
//        ToolbarItem(placement: .bottomBar) {
//            Button("Sort", action: sort)
//        }
//    }
//}


struct ContentView: View {
    
    @EnvironmentObject var calendarData: CalendarData
        
    var body: some View {
        let events = self.calendarData.events
        List {
            ForEach(events, id: \.id) { event in
                if let calendar = self.calendarData.calenderLookup[event.calendarIdentifier] {
                    ContentViewRow(event: event, calendar: calendar)
                }
            }
        }
 
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(with)
//    }
//}
