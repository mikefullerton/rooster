//
//  MainView.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/20/20.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationView {
            
            CalendarPreferencesView()
            ContentView()
        
//            .toolbar {
////                ToolbarItem(placement: .primaryAction) {
////                    Text("hello")
////                }
//            }
        }
        .frame(minWidth:400, idealWidth:500, maxWidth:1000)

     
    }
}

//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
