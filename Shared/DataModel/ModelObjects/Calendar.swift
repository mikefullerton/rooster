//
//  Calender.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation

struct Calendar: Identifiable, CustomStringConvertible, Equatable, Hashable  {

    let title: String
    let id: String
    let ekCalendarID: String
    let sourceTitle: String
    let sourceIdentifier: String
    let cgColor: CGColor?
    
    // modifiable
    var isSubscribed: Bool
    
    init(withIdentifier identifier: String,
         ekCalendarID: String,
         title: String,
         sourceTitle: String,
         sourceIdentifier: String,
         isSubscribed: Bool,
         color: CGColor?) {
        
        self.id = identifier
        self.ekCalendarID = ekCalendarID
        self.title = title
        self.sourceTitle = sourceTitle
        self.sourceIdentifier = sourceIdentifier
        self.isSubscribed = isSubscribed
        self.cgColor = color
    }
    
    var description: String {
        return "\(type(of:self)): \(self.sourceTitle): \(self.title), isSubscribed: \(self.isSubscribed)"
    }
    
    static func == (lhs: Calendar, rhs: Calendar) -> Bool {
        return  lhs.id == rhs.id &&
                lhs.title == rhs.title &&
                lhs.isSubscribed == rhs.isSubscribed &&
                lhs.sourceTitle == rhs.sourceTitle &&
                lhs.sourceIdentifier == rhs.sourceIdentifier
    }
 
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}


