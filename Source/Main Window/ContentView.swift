//
//  ContentView.swift
//  Shared
//
//  Created by Mike Fullerton on 11/13/20.
//

import SwiftUI

struct ContentView: View {
    
//    @ObservedObject var calendarData: CalendarData
    
    @EnvironmentObject var calendarData: CalendarData
        
    var body: some View {
        let events = self.calendarData.events
        
        List {
            ForEach(events, id: \.id) { event in
                ContentViewRow(event: event)
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(with)
//    }
//}
