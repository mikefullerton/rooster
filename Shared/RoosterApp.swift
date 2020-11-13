//
//  RoosterApp.swift
//  Shared
//
//  Created by Mike Fullerton on 11/13/20.
//

import SwiftUI

@main
struct RoosterApp: App {
    
    init() {
        CalendarManager.instance.requestAccess()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
