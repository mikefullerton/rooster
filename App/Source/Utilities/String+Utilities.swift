//
//  String+Utilities.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation

extension String {
    func detectURLs() -> [URL] {
        var urls: [URL] = []
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            for match in matches {
                if let matchURL = match.url {
                    urls.append(matchURL)
                }
            }
        }
        return urls
    }
}
