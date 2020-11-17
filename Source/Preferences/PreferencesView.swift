//
//  PreferencesView.swift
//  Rooster
//
//  Created by Mike Fullerton on 11/14/20.
//

import SwiftUI

struct PreferencesView: View {
    
    var body: some View {
        List(AlarmController.instance.calendarManager.data.calendars) { calendar in
            PreferenceRow(calendar: calendar)
        }
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
