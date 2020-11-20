//
//  PreferencesRow.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/16/20.
//

import SwiftUI

struct CheckBox: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    typealias UIViewType = UISwitch
    
    @Binding var calendar: EventKitCalendar
    
    func makeUIView(context: Context) -> UISwitch {
        let checkbox = UISwitch()
        checkbox.preferredStyle = .checkbox
        
        checkbox.addTarget(context.coordinator,
                           action: #selector(Coordinator.handleToggle(sender:)),
                           for: .valueChanged)

        
        return checkbox
    }
    
    func updateUIView(_ uiView: UISwitch, context: Context) {
        uiView.isOn = self.calendar.isSubscribed
        uiView.title = self.calendar.title
    }
    
    class Coordinator: NSObject {
       var control: CheckBox

       init(_ control: CheckBox) {
           self.control = control
       }

       @objc func handleToggle(sender: UISwitch) {
            self.control.calendar.set(subscribed: sender.isOn)
       }
   }
}


struct CalendarPreferenceRow: View {
    @State var calendar: EventKitCalendar
//    @State var isSubscribed: Bool = false
//    @State var title: String = ""
        
//    func toggle() {
//        self.isSubscribed = !self.isSubscribed
//        self.calendar.set(subscribed: self.isSubscribed)
//    }
    
    var body: some View {
        CheckBox(calendar: $calendar)
//        .onAppear(perform: {
//            self.isSubscribed = self.calendar.isSubscribed
//            self.title = self.calendar.title
//        })
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
