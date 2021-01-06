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
    
    @EnvironmentObject var dataModel: DataModel
        
    var body: some View {
        let events = self.dataModel.events
        List {
            ForEach(events, id: \.id) { event in
                if let calendar = self.dataModel.calendar(forIdentifier: event.uniqueID) {
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
