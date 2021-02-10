//
//  MenuBarPreferences.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/2/21.
//

import Foundation

struct MenuBarPreferences: CustomStringConvertible, Codable {
    
    struct Options: OptionSet, CustomStringConvertible, Codable {
        let rawValue: Int
        
        static let showIcon             = Options(rawValue: 1 << 1)
        static let countDown            = Options(rawValue: 1 << 2)
        static let popoverView          = Options(rawValue: 1 << 3)
        static let blink                = Options(rawValue: 1 << 4)
        static let shortCountdownFormat = Options(rawValue: 1 << 6)

        static let all:Options = [ .showIcon, .countDown, .popoverView, .blink, .shortCountdownFormat ]

        static let `default`:Options = [ .showIcon, .countDown, .popoverView, .blink ]

        init(rawValue: Int) {
            self.rawValue = rawValue
        }
    
        static var descriptions: [(Self, String)] = [
            (.showIcon, "showIcon"),
            (.countDown, "countDown"),
            (.popoverView, "popoverView"),
            (.blink, "blink"),
            (.shortCountdownFormat, "shortCoundownFormat"),
        ]

        var description: String {
            let result: [String] = Self.descriptions.filter { contains($0.0) }.map { $0.1 }
            return "\(type(of:self)): (rawValue: \(self.rawValue)) \(result)"
        }
    }
    
    var options: Options
    
    init(with options: Options) {
        self.options = options
    }
    
    init() {
        self.init(with: .default)
    }

    var description: String {
        return "\(type(of: self)): \(self.options)"
    }
    
    enum KeyEquivalents: String {
        case stopAlarms = "stopAlarms"
        case showPreferences = "showPreferences"
        case bringToFrong = "bringToFront"
    }
    
    func keyEquivalent(for equivalent: KeyEquivalents) -> String {
        
        return ""
    }
}
