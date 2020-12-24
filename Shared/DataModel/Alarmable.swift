//
//  Alarmable.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation

protocol Alarmable: CustomStringConvertible, Loggable {
    var alarm: EventKitAlarm { get }
    var id: String { get }
    var title: String { get }
    var calendar: EventKitCalendar { get }
    var location: String? { get }
    var notes: String? { get }
    var url: URL? { get }
    var noteURLS: [URL]? { get }
    var isSubscribed: Bool { get }
}

extension Alarmable {
    
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
