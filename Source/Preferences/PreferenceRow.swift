//
//  PreferencesRow.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/16/20.
//

import SwiftUI

struct PreferenceRow: View {
    var calendar: Calendar
    
    var body: some View {
        Text("\(calendar.sourceTitle): \(calendar.title)")
    }
}

struct PreferencesRow_Previews: PreviewProvider {
    static var previews: some View {
        
        ForEach(testCalendars, id: \.id) { calendar in
            PreferenceRow(calendar: calendar)
        }
    }
}
