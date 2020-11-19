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


func shortDateString(_ date: Date) -> String {
    return DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
}

struct ButtonModifier : ViewModifier {
    let kButtonWidth: CGFloat = 80.0
    let kButtonHeight: CGFloat = 40.0

    let buttonTextColor: Color
    
    init(withButtonTextColor buttonTextColor: Color) {
        self.buttonTextColor = buttonTextColor
    }
    
    func body(content: Content) -> some View {
            content
                .frame(width: kButtonWidth, height: kButtonHeight, alignment: .center)
                .foregroundColor(self.buttonTextColor)
                .background(Color.gray)
                .cornerRadius(40)
                .buttonStyle(BorderlessButtonStyle())
        }
}

struct ContentViewRow: View {
    var event: EventKitEvent
    var startDate: String = ""
    var endDate: String = ""
    var title: String = ""
    var isFiring: Bool = false
    var isInProgress: Bool = false
    var color = Color.primary
    var calendar: String
    var calendarSource: String
    
    init(event: EventKitEvent) {
        self.event = event
        self.title = event.title
        self.startDate = shortDateString(event.startDate)
        self.endDate = shortDateString(event.endDate)
        self.isFiring = event.isFiring
        self.isInProgress = event.isInProgress
        self.calendar = event.calendar.title
        self.calendarSource = event.calendar.sourceTitle
        
        if event.isInProgress {
            self.color = Color.red
        }
        print("got new event: \(event)")
    }
    
  
    let kRowHeight: CGFloat = 80.0
    let buttonSpaceWidth: CGFloat = 80.0

    let kTimeWidth: CGFloat = 60.0
    let kTimeHeight: CGFloat = 20.0
    

    
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
                Text("").frame(width:self.buttonSpaceWidth, height:kRowHeight, alignment: .trailing)
            }
            
            VStack(alignment: .leading) {
                Text("\(self.calendarSource): \(self.calendar)").foregroundColor(.gray)
                Text(self.title)
                Text("\(self.startDate) - \(self.endDate)").foregroundColor(self.color)
//                HStack {
//                    Text(self.startDate).frame(width: kTimeWidth, height: kTimeHeight, alignment: .trailing).foregroundColor(self.color)
//                    Text("-").foregroundColor(self.color)
//                    Text(self.endDate).frame(width: kTimeWidth, height: kTimeHeight, alignment: .leading).foregroundColor(self.color)
//                }
            }
            
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


