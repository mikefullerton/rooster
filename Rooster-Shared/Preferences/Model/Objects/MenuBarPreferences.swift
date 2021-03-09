//
//  MenuBarPreferences.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/2/21.
//

import Foundation
import RoosterCore

public struct MenuBarPreferences: CustomStringConvertible, Equatable {
    public var options: Options

    public static let `default` = MenuBarPreferences()

    public init(with options: Options) {
        self.options = options
    }

    public init() {
        self.init(with: .default)
    }

    public var description: String {
        "\(type(of: self)): \(self.options)"
    }

    public enum KeyEquivalents: String {
        case stopAlarms = "stopAlarms"
        case showPreferences = "showPreferences"
        case bringToFrong = "bringToFront"
    }

    public func keyEquivalent(for equivalent: KeyEquivalents) -> String {
        ""
    }
}

extension MenuBarPreferences: Codable {
    private enum CodingKeys: String, CodingKey {
        case options
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.options = try values.decodeIfPresent(Options.self, forKey: .options) ?? Self.default.options
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.options, forKey: .options)
    }
}

extension MenuBarPreferences {
    public struct Options: DescribeableOptionSet {
        public let rawValue: Int

        public static let zero                  = Options([])
        public static let showIcon              = Options(rawValue: 1 << 1)
        public static let countDown             = Options(rawValue: 1 << 2)
        public static let popoverView           = Options(rawValue: 1 << 3)
        public static let blink                 = Options(rawValue: 1 << 4)
        public static let shortCountdownFormat  = Options(rawValue: 1 << 6)

        public static let all: Options = [ .showIcon, .countDown, .popoverView, .blink, .shortCountdownFormat ]

        public static let `default`:Options = [ .showIcon, .countDown, .popoverView, .blink ]

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static var descriptions: [(Self, String)] = [
            (.showIcon, "showIcon"),
            (.countDown, "countDown"),
            (.popoverView, "popoverView"),
            (.blink, "blink"),
            (.shortCountdownFormat, "shortCoundownFormat")
        ]
    }
}
