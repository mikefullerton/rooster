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

struct ContentViewRow: View {
    @ObservedObject var event: Event
    var startDate: Date
    var endDate: Date
//    var isFiring: Bool
//    var isInProgress: Bool
    
    init(event: Event) {
        self.event = event
        self.startDate = event.startDate
        self.endDate = event.endDate
//        self.isFiring = event.isFiring
//        self.isInProgress = event.isInProgress
        
        print("got new event: \(event)")
    }
    
    func shortDateString(_ date: Date) -> String {
        return DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
    }

    let height: CGFloat = 80.0
    let buttonSpaceWidth: CGFloat = 80.0

    // these seem to be cached ?
    
    var isFiring: Bool {
        return self.event.isFiring
    }
    
    var isInProgress: Bool  {
        return self.event.isInProgress
    }
    
//    var startDate: Date {
//        return self.event.startDate
//    }
//    
//    var endDate : Date {
//        return self.event.endDate
//    }
    
    var body: some View {
        if self.isFiring {
            HStack{
                Button(action: {
                    print("Stop button pressed")
                    self.event.stopAlarm()
                }) {
                    Text("Stop")
                }
                .frame(width: 80, height: self.height / 2, alignment: .center)
                .foregroundColor(.red)
                .background(Color.gray)
                .cornerRadius(40)
                .buttonStyle(BorderlessButtonStyle())
                .disabled(false)
                
                Text(self.shortDateString(self.startDate)).frame(width: 60, height: self.height, alignment: .trailing).foregroundColor(.red)
                Text("-").foregroundColor(.red)
                Text(self.shortDateString(self.endDate)).frame(width: 60, height: self.height, alignment: .leading).foregroundColor(.red)
                Text(self.event.title).foregroundColor(.red)
            }
        } else if self.isInProgress {
            HStack{
                Button(action: {
                    print("Stop button pressed")
                    AlarmController.instance.stopAlarm(forEvent: self.event)
                }) {
                    Text("Stop")
                }
                .frame(width: 80, height: self.height / 2, alignment: .center)
                .foregroundColor(Color(UIColor.lightGray))
                .background(Color.gray)
                .cornerRadius(40)
                .buttonStyle(BorderlessButtonStyle())
                .disabled(true)
                Text(self.shortDateString(self.startDate)).frame(width: 60, height: self.height, alignment: .trailing).foregroundColor(.red)
                Text("-").foregroundColor(.red)
                Text(self.shortDateString(self.endDate)).frame(width: 60, height: self.height, alignment: .leading).foregroundColor(.red)
                Text(self.event.title).foregroundColor(.red)
            }
        } else {
            HStack{
                Text("").frame(width:self.buttonSpaceWidth, height:self.height, alignment: .trailing)
                Text(self.shortDateString(self.startDate)).frame(width: 60, height: self.height, alignment: .trailing)
                Text("-")
                Text(self.shortDateString(self.endDate)).frame(width: 60, height: self.height, alignment: .leading)
                Text(self.event.title)
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


