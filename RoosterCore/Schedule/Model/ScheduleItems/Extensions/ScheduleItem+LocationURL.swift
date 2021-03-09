//
//  EventKitCalendarItem+LocationURL.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/15/21.
//

import Foundation

extension ScheduleItem {
    public func openLocationURL() -> Bool {
        if let url = self.knownLocationURL {
            #if os(macOS)
            CoreControllers.shared.systemUtilities.openLocationURL(url) { success, error in
                self.logger.log("""
                    Opened URL: \(url). \
                    Success: \(success), \
                    error: \(error != nil ? error!.localizedDescription : "nil")
                    """)
            }
            #endif

            #if targetEnvironment(macCatalyst)
            CoreControllers.shared.appKitPlugin.utilities.openLocationURL(url) { success, error in
                self.logger.log("""
                    Opened URL: \(url). \
                    Success: \(success), \
                    error: \(error != nil ? error!.localizedDescription : "nil")
                    """)
            }
            #endif

            return true
        } else {
            self.logger.log("No location url found")
        }

        return false
    }

    public func bringLocationAppsToFront() {
        if let url = self.knownLocationURL {
            #if os(macOS)
            CoreControllers.shared.systemUtilities.bringLocationAppsToFront(for: url)
            #endif

            #if targetEnvironment(macCatalyst)
            CoreControllers.shared.appKitPlugin.utilities.bringLocationAppsToFront(for: url)
            #endif
        } else {
            self.logger.log("No location url found")
        }
    }

    public var knownLocationURL: URL? {
        if let url = self.findURL(containing: "appleinc.webex.com/appleinc") {
            return url
        }

        if let url = self.findURL(containing: "appleinc.webex.com/meet") {
            return url
        }

        return nil
    }

    public func findURL(containing string: String) -> URL? {
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

extension String {
    // swiftlint:disable legacy_objc_type

    func detectURLs() -> [URL] {
        var urls: [URL] = []
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
            let lines = self.split(separator: "\n")
            for line in lines {
                let matches = detector.matches(in: String(line), options: [], range: NSRange(location: 0, length: line.count))
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
    // swiftlint:enable legacy_objc_type
}
