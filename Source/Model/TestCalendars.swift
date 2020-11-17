//
//  TestCalendars.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/16/20.
//

import Foundation

struct TestCalendar: Calendar, Identifiable {
    var id: String
    
    var isSubscribed: Bool
    
    var title: String
    
    var sourceTitle: String

    var sourceIdentifier: String

    init(withTitle title: String,
         sourceTitle: String,
         sourceID: String,
         id: String,
         isSubscribed: Bool) {
        self.title = title
        self.id = id
        self.isSubscribed = isSubscribed
        self.sourceTitle = sourceTitle
        self.sourceIdentifier = sourceID
    }
}

let testCalendars: [TestCalendar] = [
        TestCalendar(withTitle:"Test 1", sourceTitle:"Apple", sourceID: "apple", id:"test1", isSubscribed:true),
        TestCalendar(withTitle:"Test 2", sourceTitle:"iCloud", sourceID: "icloud", id:"test2", isSubscribed:false),
        TestCalendar(withTitle:"Test 3", sourceTitle:"google", sourceID: "google", id:"test3", isSubscribed:true)
]
