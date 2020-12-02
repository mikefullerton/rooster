//
//  EventKitEvent+Utilities.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation
//import UIKit

extension EventKitEvent {
    func findURL(containing string: String) -> URL? {
        if let location = self.location,
           location.contains(string),
           let url = URL(string: location) {
            return url
        }
        
        if let url = self.eventURL,
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
