//
//  ContentViewRow.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/16/20.
//

import Foundation
import SwiftUI

extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return self
        }
    }
}

struct ButtonModifier : ViewModifier {
    
    let buttonTextColor: Color
    
    init(withButtonTextColor buttonTextColor: Color) {
        self.buttonTextColor = buttonTextColor
    }
    
    func body(content: Content) -> some View {
            content
                .frame(width: 80, height: 40, alignment: .center)
                .foregroundColor(self.buttonTextColor)
                .background(Color.gray)
                .cornerRadius(40)
                .buttonStyle(BorderlessButtonStyle())
        }
}

func shortDateString(_ date: Date) -> String {
    return DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
}


struct ContentViewRow: View {
//    @ObservedObject var event: EventKitEvent
//
//    @State var startDate: String = ""
//    @State var endDate: String = ""
//    @State var title: String = ""
//    @State var isFiring: Bool = false
//    @State var isInProgress: Bool = false

    var event: EventKitEvent
    var startDate: String = ""
    var endDate: String = ""
    var title: String = ""
    var isFiring: Bool = false
    var isInProgress: Bool = false
    
    init(event: EventKitEvent) {
        self.event = event
        self.title = event.title
        self.startDate = shortDateString(event.startDate)
        self.endDate = shortDateString(event.endDate)
        self.isFiring = event.isFiring
        self.isInProgress = event.isInProgress
        print("got new event: \(event)")
    }
    
  
    let height: CGFloat = 80.0
    let buttonSpaceWidth: CGFloat = 80.0

    // these seem to be cached ?
    
//    var isFiring: Bool {
//        return self.event.isFiring
//    }
//
//    var isInProgress: Bool  {
//        return self.event.isInProgress
//    }
//
//    var startDate: Date {
//        return self.event.startDate
//    }
//    
//    var endDate : Date {
//        return self.event.endDate
//    }
    
    var body: some View {
        HStack{
            if self.isFiring {
                Button(action: {
                    print("Stop button pressed")
                    self.event.stopAlarm()
                }) {
                    Text("Stop")
                }
                .modifier(ButtonModifier(withButtonTextColor: Color.red))
                .disabled(false)
                
            } else if self.isInProgress {
                Button(action: {
                    print("Disabled top button pressed")
                }) {
                    Text("Stop")
                }
                .modifier(ButtonModifier(withButtonTextColor:Color(UIColor.lightGray)))
                .disabled(true)
            } else {
                Text("").frame(width:self.buttonSpaceWidth, height:self.height, alignment: .trailing)
            }
             
            Text(self.startDate).frame(width: 60, height: self.height, alignment: .trailing).foregroundColor(.red)
            Text("-").foregroundColor(.red)
            Text(self.endDate).frame(width: 60, height: self.height, alignment: .leading).foregroundColor(.red)
            Text(self.title).foregroundColor(.red)
        }
//        .onAppear(perform: {
//            self.title = self.event.title
//            self.startDate = self.shortDateString(self.event.startDate)
//            self.endDate = self.shortDateString(self.event.endDate)
//            self.isFiring = self.event.isFiring
//            self.isInProgress = self.event.isInProgress
//        })
//        .onReceive(event.objectWillChange, perform: { newEvent in
//            print("\(newEvent)")
//            self.title = self.event.title
//            self.startDate = self.shortDateString(self.event.startDate)
//            self.endDate = self.shortDateString(self.event.endDate)
//            self.isFiring = self.event.isFiring
//            self.isInProgress = self.event.isInProgress
//        })
//
    }
}

struct DateContentView<Content: View> : View {
    let content: Content
//    @ObservedObject var event: EventKitEvent

    let height: CGFloat = 80.0
    let buttonSpaceWidth: CGFloat = 80.0
    var startDate: Date
    var endDate: Date
    var title: String

    init(event: EventKitEvent,
        @ViewBuilder content: () -> Content) {
//        self.event = event
        self.content = content()
        self.startDate = event.startDate
        self.endDate = event.endDate
        self.title = event.title
        
        print(title)
    }
    
    func shortDateString(_ date: Date) -> String {
        return DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
    }

    var body: some View {
        HStack {
            Text(self.shortDateString(self.startDate)).frame(width: 60, height: self.height, alignment: .trailing)
            Text("-")
            Text(self.shortDateString(self.endDate)).frame(width: 60, height: self.height, alignment: .leading)
            Text(self.title)
        }
    }
}

//struct ContentViewRow: PreviewProvider {
//    static var previews: some View {
//
//        ForEach(testCalendars, id: \.id) { calendar in
//            ContentView(calendar: calendar)
//        }
//    }
//}


