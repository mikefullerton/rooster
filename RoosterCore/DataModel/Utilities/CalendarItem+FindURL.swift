//
//  RCCalendarItem+FindURL.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/8/21.
//

import Foundation

extension String {
    func detectURLs() -> [URL] {
        var urls: [URL] = []
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
            let lines = self.split(separator: "\n")
            for line in lines {
                let matches = detector.matches(in: String(line), options: [], range: NSMakeRange(0, line.count))
                for match in matches {
                    if let matchURL = match.url {
                        urls.append(matchURL)
                    }
                }
            }
            
            
        } else {
            print("failed to create data detector")
        }
        return urls
    }
}

extension RCCalendarItem {

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
        
        if let notes = self.notes {
            let urls = notes.detectURLs()
            for url in urls {
                if url.absoluteString.contains(string) {
                    return url
                }
            }
        }
        
        return nil
    }
}
