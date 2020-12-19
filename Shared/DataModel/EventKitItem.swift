//
//  EventKitItem.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation

protocol Alarmable {
    var alarm: EventKitAlarm { get }
}

protocol EventKitItem: Alarmable, CustomStringConvertible, Hashable {
    
    associatedtype ItemType
    
    var id: String { get }
    var title: String { get }
    var location: String? { get }
    var notes: String? { get }
    var url: URL? { get }
    var noteURLS: [URL]? { get }
    var calendar: EventKitCalendar { get }
    var isSubscribed: Bool { get }
    
    func updateAlarm(_ alarm: EventKitAlarm) -> ItemType
}

extension EventKitItem {
    
    func findURL(containing string: String) -> URL? {
        if let location = self.location,
           location.contains(string),
           let url = URL(string: location) {
            return url
        }
        
        if let url = self.url,
           url.absoluteString.contains(string) {
            return url
        }
        
        if let noteURLs = self.noteURLS {
            for url in noteURLs {
                if url.absoluteString.contains(string) {
                    return url
                }
            }
        }
        
        return nil
    }
    
    
}

