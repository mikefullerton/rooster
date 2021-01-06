//
//  CalendarItem.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation

protocol CalendarItem: CustomStringConvertible, Loggable {
    var id: String { get }

    var alarm: Alarm { get set }
    var title: String { get }
    var calendar: Calendar { get }
    var location: String? { get }
    var notes: String? { get }
    var url: URL? { get }
    var noteURLS: [URL]? { get }
    var isSubscribed: Bool { get set }
    
    func isEqualTo(_ item: CalendarItem) -> Bool
}

extension CalendarItem {
    
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
